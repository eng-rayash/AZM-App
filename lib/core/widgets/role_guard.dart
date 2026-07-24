import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../constants/enums.dart';
import '../../features/company/providers/company_providers.dart';

/// RVIOS — Role Guard Widget
///
/// Wraps UI elements that should only be visible to users
/// with a specific role or module access.
///
/// Usage:
/// ```dart
/// RoleGuard(
///   requiredRole: UserRole.admin,
///   child: DeleteButton(),
/// )
///
/// ModuleGuard(
///   module: AppModule.hrm,
///   child: HrmTab(),
/// )
/// ```
class RoleGuard extends ConsumerWidget {
  const RoleGuard({
    super.key,
    required this.child,
    this.requiredRole,
    this.allowedRoles,
    this.fallback,
  }) : assert(
          requiredRole != null || allowedRoles != null,
          'RoleGuard: specify either requiredRole or allowedRoles',
        );

  /// Minimum role level required (owner=0, down to guest=9)
  final UserRole? requiredRole;

  /// Explicit list of allowed roles
  final List<UserRole>? allowedRoles;

  /// Widget to show when access is denied (null = show nothing)
  final Widget? fallback;

  /// The protected content
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentRole = ref.watch(activeMemberRoleProvider);
    final hasAccess = _checkAccess(currentRole);

    if (hasAccess) return child;
    return fallback ?? const SizedBox.shrink();
  }

  bool _checkAccess(UserRole currentRole) {
    if (allowedRoles != null) {
      return allowedRoles!.contains(currentRole);
    }
    if (requiredRole != null) {
      // Role hierarchy: lower value = higher privilege
      return currentRole.level <= requiredRole!.level;
    }
    return false;
  }
}

/// Guards a widget behind module availability.
///
/// The module must be in the company's active plan.
class ModuleGuard extends ConsumerWidget {
  const ModuleGuard({
    super.key,
    required this.module,
    required this.child,
    this.fallback,
  });

  final AppModule module;
  final Widget child;
  final Widget? fallback;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAvailable = ref.watch(isModuleAvailableProvider(module));

    if (isAvailable) return child;
    return fallback ?? const SizedBox.shrink();
  }
}

/// Guards a widget behind both role AND module checks.
class RoleAndModuleGuard extends ConsumerWidget {
  const RoleAndModuleGuard({
    super.key,
    required this.module,
    required this.child,
    this.requiredRole,
    this.allowedRoles,
    this.fallback,
  });

  final AppModule module;
  final UserRole? requiredRole;
  final List<UserRole>? allowedRoles;
  final Widget child;
  final Widget? fallback;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentRole = ref.watch(activeMemberRoleProvider);
    final isModuleAvailable = ref.watch(isModuleAvailableProvider(module));

    final hasRoleAccess = allowedRoles != null
        ? allowedRoles!.contains(currentRole)
        : (requiredRole != null
            ? currentRole.level <= requiredRole!.level
            : true);

    if (isModuleAvailable && hasRoleAccess) return child;
    return fallback ?? const SizedBox.shrink();
  }
}

/// Shows a "Locked" placeholder for unavailable modules with upgrade CTA.
class ModuleLockedCard extends StatelessWidget {
  const ModuleLockedCard({
    super.key,
    required this.module,
    this.height = 140,
  });

  final AppModule module;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.lock_outline_rounded,
              color: Colors.grey.shade400, size: 32),
          const SizedBox(height: 8),
          Text(
            module.arabicLabel,
            style: TextStyle(
              fontFamily: 'Panorama',
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'هذه الميزة تتطلب ترقية الباقة',
            style: TextStyle(
              fontFamily: 'Panorama',
              fontSize: 11,
              color: Colors.grey.shade400,
            ),
          ),
        ],
      ),
    );
  }
}