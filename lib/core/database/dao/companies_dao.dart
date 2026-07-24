import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/tenant/companies_table.dart';
import '../tables/tenant/company_members_table.dart';
import '../tables/tenant/invitations_table.dart';
import '../tables/tenant/audit_logs_table.dart';

part 'companies_dao.g.dart';

/// RVIOS — Companies DAO
///
/// Handles all Multi-Tenant operations: company creation, member management,
/// invitations, and audit logging.
@DriftAccessor(tables: [Companies, CompanyMembers, Invitations, AuditLogs])
class CompaniesDao extends DatabaseAccessor<AppDatabase>
    with _$CompaniesDaoMixin {
  CompaniesDao(super.db);

  // ─────────────────────────────────────────────
  // Companies
  // ─────────────────────────────────────────────

  /// Get all active companies (non-deleted)
  Future<List<Company>> getAllCompanies() =>
      (select(companies)..where((c) => c.isDeleted.equals(false))).get();

  /// Watch all active companies
  Stream<List<Company>> watchAllCompanies() =>
      (select(companies)..where((c) => c.isDeleted.equals(false))).watch();

  /// Get a company by its syncId
  Future<Company?> getCompanyBySyncId(String syncId) =>
      (select(companies)..where((c) => c.syncId.equals(syncId)))
          .getSingleOrNull();

  /// Get a company by its workspace slug (for login)
  Future<Company?> getCompanyBySlug(String slug) =>
      (select(companies)..where((c) => c.workspaceSlug.equals(slug)))
          .getSingleOrNull();

  /// Get a company by its generated code (e.g. CMP-8X7Q2K)
  Future<Company?> getCompanyByCode(String code) =>
      (select(companies)..where((c) => c.companyCode.equals(code)))
          .getSingleOrNull();

  /// Insert a new company; returns the row ID
  Future<int> insertCompany(CompaniesCompanion company) =>
      into(companies).insert(company);

  /// Update a company
  Future<bool> updateCompany(CompaniesCompanion company, String syncId) =>
      (update(companies)..where((c) => c.syncId.equals(syncId)))
          .write(company)
          .then((rows) => rows > 0);

  /// Soft-delete a company
  Future<void> softDeleteCompany(String syncId) =>
      (update(companies)..where((c) => c.syncId.equals(syncId))).write(
        CompaniesCompanion(
          isDeleted: const Value(true),
          updatedAt: Value(DateTime.now().millisecondsSinceEpoch),
        ),
      );

  /// Check if a workspace slug is available
  Future<bool> isSlugAvailable(String slug) async {
    final result = await (select(companies)
          ..where((c) =>
              c.workspaceSlug.equals(slug) & c.isDeleted.equals(false)))
        .getSingleOrNull();
    return result == null;
  }

  // ─────────────────────────────────────────────
  // Company Members
  // ─────────────────────────────────────────────

  /// Get all active members of a company
  Future<List<CompanyMember>> getMembersOfCompany(String companySyncId) =>
      (select(companyMembers)
            ..where((m) =>
                m.companySyncId.equals(companySyncId) &
                m.isDeleted.equals(false) &
                m.isActive.equals(true)))
          .get();

  /// Watch members of a company (realtime)
  Stream<List<CompanyMember>> watchMembersOfCompany(String companySyncId) =>
      (select(companyMembers)
            ..where((m) =>
                m.companySyncId.equals(companySyncId) &
                m.isDeleted.equals(false) &
                m.isActive.equals(true)))
          .watch();

  /// Get a specific membership
  Future<CompanyMember?> getMembership({
    required String companySyncId,
    required String userSyncId,
  }) =>
      (select(companyMembers)
            ..where((m) =>
                m.companySyncId.equals(companySyncId) &
                m.userSyncId.equals(userSyncId) &
                m.isDeleted.equals(false)))
          .getSingleOrNull();

  /// Insert a new membership
  Future<int> insertMember(CompanyMembersCompanion member) =>
      into(companyMembers).insert(member);

  /// Update a membership (e.g. role change)
  Future<bool> updateMember(
      CompanyMembersCompanion member, String companySyncId, String userSyncId) =>
      (update(companyMembers)
            ..where((m) =>
                m.companySyncId.equals(companySyncId) &
                m.userSyncId.equals(userSyncId)))
          .write(member)
          .then((rows) => rows > 0);

  /// Deactivate a member (without soft delete — keeps the audit trail)
  Future<void> deactivateMember(String companySyncId, String userSyncId) =>
      (update(companyMembers)
            ..where((m) =>
                m.companySyncId.equals(companySyncId) &
                m.userSyncId.equals(userSyncId)))
          .write(
        CompanyMembersCompanion(
          isActive: const Value(false),
          updatedAt: Value(DateTime.now().millisecondsSinceEpoch),
        ),
      );

  /// Mark onboarding as completed for a member
  Future<void> completeOnboarding(
      String companySyncId, String userSyncId) =>
      (update(companyMembers)
            ..where((m) =>
                m.companySyncId.equals(companySyncId) &
                m.userSyncId.equals(userSyncId)))
          .write(
        CompanyMembersCompanion(
          onboardingCompleted: const Value(true),
          joinedAt: Value(DateTime.now()),
          updatedAt: Value(DateTime.now().millisecondsSinceEpoch),
        ),
      );

  // ─────────────────────────────────────────────
  // Invitations
  // ─────────────────────────────────────────────

  /// Get all pending invitations for a company
  Future<List<Invitation>> getPendingInvitations(String companySyncId) =>
      (select(invitations)
            ..where((i) =>
                i.companySyncId.equals(companySyncId) &
                i.status.equals(0) & // pending
                i.isDeleted.equals(false)))
          .get();

  /// Get invitation by token (for redemption)
  Future<Invitation?> getInvitationByToken(String token) =>
      (select(invitations)..where((i) => i.token.equals(token)))
          .getSingleOrNull();

  /// Get invitation by employee code
  Future<Invitation?> getInvitationByEmployeeCode(String code) =>
      (select(invitations)
            ..where((i) =>
                i.employeeCode.equals(code) & i.status.equals(0)))
          .getSingleOrNull();

  /// Insert a new invitation
  Future<int> insertInvitation(InvitationsCompanion invitation) =>
      into(invitations).insert(invitation);

  /// Mark invitation as accepted
  Future<void> acceptInvitation(String token, String resultingUserSyncId) =>
      (update(invitations)..where((i) => i.token.equals(token))).write(
        InvitationsCompanion(
          status: const Value(1), // accepted
          usedAt: Value(DateTime.now()),
          resultingUserSyncId: Value(resultingUserSyncId),
          updatedAt: Value(DateTime.now().millisecondsSinceEpoch),
        ),
      );

  /// Cancel an invitation
  Future<void> cancelInvitation(String token) =>
      (update(invitations)..where((i) => i.token.equals(token))).write(
        InvitationsCompanion(
          status: const Value(3), // cancelled
          updatedAt: Value(DateTime.now().millisecondsSinceEpoch),
        ),
      );

  // ─────────────────────────────────────────────
  // Audit Logs
  // ─────────────────────────────────────────────

  /// Insert an audit log entry
  Future<int> insertAuditLog(AuditLogsCompanion log) =>
      into(auditLogs).insert(log);

  /// Get audit logs for a company (latest first, paginated)
  Future<List<AuditLog>> getAuditLogs(
    String companySyncId, {
    int limit = 50,
    int offset = 0,
  }) =>
      (select(auditLogs)
            ..where((l) => l.companySyncId.equals(companySyncId))
            ..orderBy([(l) => OrderingTerm.desc(l.createdAt)])
            ..limit(limit, offset: offset))
          .get();

  /// Get audit logs for a specific actor
  Future<List<AuditLog>> getAuditLogsByActor(
    String companySyncId,
    String actorSyncId,
  ) =>
      (select(auditLogs)
            ..where((l) =>
                l.companySyncId.equals(companySyncId) &
                l.actorSyncId.equals(actorSyncId))
            ..orderBy([(l) => OrderingTerm.desc(l.createdAt)])
            ..limit(100))
          .get();

  /// Log a user action (convenience helper)
  Future<void> logAction({
    required String actorSyncId,
    required String companySyncId,
    required String action,
    String? entityType,
    String? entitySyncId,
    String? description,
    String? oldValueJson,
    String? newValueJson,
    String? ipAddress,
    String? platform,
    int severity = 0,
  }) =>
      insertAuditLog(
        AuditLogsCompanion(
          syncId: Value(DateTime.now().microsecondsSinceEpoch.toString()),
          createdAt: Value(DateTime.now().millisecondsSinceEpoch),
          updatedAt: Value(DateTime.now().millisecondsSinceEpoch),
          isDeleted: const Value(false),
          actorSyncId: Value(actorSyncId),
          companySyncId: Value(companySyncId),
          action: Value(action),
          entityType: Value(entityType),
          entitySyncId: Value(entitySyncId),
          description: Value(description),
          oldValueJson: Value(oldValueJson),
          newValueJson: Value(newValueJson),
          ipAddress: Value(ipAddress),
          platform: Value(platform),
          severity: Value(severity),
        ),
      ).then((_) {});
}