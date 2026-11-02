import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../core/constants/enums.dart';
import '../../core/database/app_database.dart';
import '../../core/database/providers/database_providers.dart';
import '../../core/router/route_names.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/neu_colors.dart';
import '../widgets/neu_card.dart';
import '../../core/design/azm_tokens.dart';

// تعريف [EntityLinkType] انتقل إلى `core/constants/enums.dart`:
// تعداد مجال لا عرض، ومكانه مع بقية تعدادات النظام لا داخل widget.
//
// ما بقي هنا هو مظهره وحده — الأيقونة واللون شأن عرض، ولو عاشا في
// التعداد لجرّا طبقة الثوابت إلى الاعتماد على طبقة الثيم.

/// مظهر نوع الكيان — أيقونته ولونه في الواجهة.
extension EntityLinkTypeVisuals on EntityLinkType {
  IconData get icon {
    switch (this) {
      case EntityLinkType.none:
        return Icons.link_off_rounded;
      case EntityLinkType.meeting:
        return Icons.groups_rounded;
      case EntityLinkType.followup:
        return Icons.replay_rounded;
      case EntityLinkType.client:
        return Icons.supervisor_account_rounded;
      case EntityLinkType.project:
        return Icons.work_rounded;
      case EntityLinkType.employee:
        return Icons.badge_rounded;
      case EntityLinkType.invoice:
        return Icons.receipt_long_rounded;
      case EntityLinkType.expense:
        return Icons.money_off_rounded;
      case EntityLinkType.revenue:
        return Icons.attach_money_rounded;
      case EntityLinkType.contract:
        return Icons.description_rounded;
      case EntityLinkType.directive:
        return Icons.policy_rounded;
      case EntityLinkType.contact:
        return Icons.contact_phone_rounded;
      case EntityLinkType.supplier:
        return Icons.local_shipping_rounded;
      case EntityLinkType.document:
        return Icons.folder_rounded;
      case EntityLinkType.appointment:
        return Icons.event_rounded;
      case EntityLinkType.note:
        return Icons.sticky_note_2_rounded;
      case EntityLinkType.other:
        return Icons.category_rounded;
    }
  }

  /// اللون يتبع معنى الكيان: المال الداخل أخضر، والخارج أحمر، والناس
  /// بلون العلامة — لا لونًا عشوائيًا لكل نوع.
  Color get color {
    switch (this) {
      case EntityLinkType.revenue:
      case EntityLinkType.invoice:
        return NeuColors.moduleIncome;
      case EntityLinkType.expense:
        return NeuColors.moduleOutgoing;
      case EntityLinkType.client:
      case EntityLinkType.employee:
      case EntityLinkType.contact:
      case EntityLinkType.supplier:
        return NeuColors.modulePeople;
      case EntityLinkType.project:
      case EntityLinkType.followup:
      case EntityLinkType.meeting:
      case EntityLinkType.appointment:
        return NeuColors.moduleDelivery;
      case EntityLinkType.contract:
      case EntityLinkType.directive:
      case EntityLinkType.document:
      case EntityLinkType.note:
        return NeuColors.moduleStructure;
      case EntityLinkType.none:
      case EntityLinkType.other:
        return NeuColors.textHint;
    }
  }
}

/// ─────────────────────────────────────────────────────────────────────────────
/// RelatedEntitiesWidget
///
/// A premium Neumorphic panel that displays all entities linked to a given
/// source entity. Supports adding new links and navigating to linked records.
///
/// Usage:
/// ```dart
/// RelatedEntitiesWidget(
///   sourceType: EntityLinkType.project,
///   sourceId: project.id,
///   sourceLabel: project.name,
/// )
/// ```
/// ─────────────────────────────────────────────────────────────────────────────
class RelatedEntitiesWidget extends ConsumerStatefulWidget {
  const RelatedEntitiesWidget({
    super.key,
    required this.sourceType,
    required this.sourceId,
    required this.sourceLabel,
  });

  final EntityLinkType sourceType;
  final int sourceId;
  final String sourceLabel;

  @override
  ConsumerState<RelatedEntitiesWidget> createState() =>
      _RelatedEntitiesWidgetState();
}

class _RelatedEntitiesWidgetState
    extends ConsumerState<RelatedEntitiesWidget> {
  List<EntityLink> _links = [];
  bool _loading = true;
  bool _expanded = true;

  @override
  void initState() {
    super.initState();
    _loadLinks();
  }

  Future<void> _loadLinks() async {
    try {
      final db = ref.read(databaseProvider);
      final links = await db.financeDao.getLinksForEntity(
        widget.sourceType.value,
        widget.sourceId,
      );
      if (mounted) setState(() { _links = links; _loading = false; });
    } catch (e) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _addLink(EntityLinkType targetType, int targetId, String targetLabel) async {
    try {
      final db = ref.read(databaseProvider);
      final now = DateTime.now().millisecondsSinceEpoch;
      await db.financeDao.insertLink(
        EntityLinksCompanion.insert(
          syncId: const Uuid().v4(),
          sourceType: widget.sourceType.value,
          sourceId: widget.sourceId,
          targetType: targetType.value,
          targetId: targetId,
          sourceLabel: Value(widget.sourceLabel),
          targetLabel: Value(targetLabel),
          createdAt: now,
          updatedAt: now,
        ),
      );
      await _loadLinks();
    } catch (e) {
      debugPrint('Error adding link: $e');
    }
  }

  Future<void> _deleteLink(int linkId) async {
    try {
      final db = ref.read(databaseProvider);
      await db.financeDao.deleteLink(linkId);
      await _loadLinks();
    } catch (e) {
      debugPrint('Error deleting link: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? NeuColors.textPrimaryDark : NeuColors.textPrimary;
    final textHint = isDark ? NeuColors.textHintDark : NeuColors.textHint;

    return NeuCard(
      isDark: isDark,
      radius: AzmRadius.sm,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ───────────────────────────────────────────────
          InkWell(
            onTap: () => setState(() => _expanded = !_expanded),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  Container(
                    width: 36, height: 36,
                    decoration: BoxDecoration(
                      color: widget.sourceType.color.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(Icons.hub_rounded, color: widget.sourceType.color, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('الكيانات المرتبطة',
                            style: AppTypography.label.copyWith(
                              color: textPrimary, fontWeight: FontWeight.w700)),
                        Text('${_links.length} ارتباط',
                            style: AppTypography.caption.copyWith(color: textHint)),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.add_link_rounded,
                      color: isDark ? NeuColors.goldAccent : NeuColors.navyDeep,
                      size: 22,
                    ),
                    onPressed: () => _showAddLinkSheet(context, isDark),
                    tooltip: 'إضافة ارتباط',
                  ),
                  Icon(
                    _expanded ? Icons.expand_less_rounded : Icons.expand_more_rounded,
                    color: textHint, size: 20,
                  ),
                ],
              ),
            ),
          ),

          // ── Divider ──────────────────────────────────────────────
          if (_expanded)
            Divider(height: 1,
                color: isDark ? NeuColors.dividerDark : NeuColors.divider),

          // ── Content ──────────────────────────────────────────────
          if (_expanded)
            _loading
                ? const Padding(
                    padding: EdgeInsets.all(24),
                    child: Center(child: CircularProgressIndicator()),
                  )
                : _links.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(children: [
                          Icon(Icons.link_off_rounded, size: 40, color: textHint),
                          const SizedBox(height: 8),
                          Text('لا توجد ارتباطات بعد',
                              style: AppTypography.bodySmall.copyWith(color: textHint)),
                          const SizedBox(height: 4),
                          Text('اضغط + لإضافة ارتباط',
                              style: AppTypography.caption.copyWith(color: textHint)),
                        ]),
                      )
                    : ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _links.length,
                        separatorBuilder: (context, index) => Divider(
                            height: 1,
                            color: isDark ? NeuColors.dividerDark : NeuColors.divider),
                        itemBuilder: (_, i) {
                          final link = _links[i];
                          final type = EntityLinkType.fromValue(link.targetType);
                          return _LinkTile(
                            link: link,
                            type: type,
                            isDark: isDark,
                            onTap: () => _navigateToEntity(context, type, link.targetId),
                            onDelete: () => _deleteLink(link.id),
                          );
                        },
                      ),
        ],
      ),
    );
  }

  void _navigateToEntity(BuildContext context, EntityLinkType type, int id) {
    switch (type) {
      case EntityLinkType.client:
        context.push(RouteNames.clientDetailPath(id));
        break;
      case EntityLinkType.project:
        context.push(RouteNames.projectDetailPath(id));
        break;
      case EntityLinkType.employee:
        context.push(RouteNames.employeeDetailPath(id));
        break;
      case EntityLinkType.invoice:
        context.push(RouteNames.invoiceDetailPath(id));
        break;
      case EntityLinkType.followup:
        context.push('${RouteNames.followupCreate}?id=$id');
        break;
      default:
        break;
    }
  }

  void _showAddLinkSheet(BuildContext context, bool isDark) {
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? NeuColors.bgColorDark : NeuColors.bgColor,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => _AddLinkSheet(
        isDark: isDark,
        sourceType: widget.sourceType,
        sourceId: widget.sourceId,
        sourceLabel: widget.sourceLabel,
        onLinkAdded: (type, id, label) async {
          Navigator.of(ctx).pop();
          await _addLink(type, id, label);
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Link Tile — individual entity link row
// ─────────────────────────────────────────────────────────────────────────────
class _LinkTile extends StatelessWidget {
  const _LinkTile({
    required this.link,
    required this.type,
    required this.isDark,
    required this.onTap,
    required this.onDelete,
  });

  final EntityLink link;
  final EntityLinkType type;
  final bool isDark;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final label = link.targetLabel ?? type.label;
    final relation = link.relation;

    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        width: 40, height: 40,
        decoration: BoxDecoration(
          color: type.color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(type.icon, color: type.color, size: 20),
      ),
      title: Text(
        label,
        style: AppTypography.body.copyWith(
          color: isDark ? NeuColors.textPrimaryDark : NeuColors.textPrimary,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: relation != null
          ? Text(relation,
              style: AppTypography.caption
                  .copyWith(color: isDark ? NeuColors.textHintDark : NeuColors.textHint))
          : Text(type.label,
              style: AppTypography.caption
                  .copyWith(color: type.color.withValues(alpha: 0.8))),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.arrow_forward_ios_rounded,
              size: 14,
              color: isDark ? NeuColors.textHintDark : NeuColors.textHint),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: () => _confirmDelete(context),
            child: const Icon(Icons.link_off_rounded,
                size: 18, color: NeuColors.danger),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('حذف الارتباط؟', textDirection: TextDirection.rtl),
        content: Text('هل تريد إزالة ارتباط "${link.targetLabel ?? type.label}"؟',
            textDirection: TextDirection.rtl),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
          TextButton(
            onPressed: () { Navigator.pop(ctx); onDelete(); },
            child: const Text('حذف', style: TextStyle(color: NeuColors.danger)),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Add Link Sheet
// ─────────────────────────────────────────────────────────────────────────────
class _AddLinkSheet extends StatefulWidget {
  const _AddLinkSheet({
    required this.isDark,
    required this.sourceType,
    required this.sourceId,
    required this.sourceLabel,
    required this.onLinkAdded,
  });

  final bool isDark;
  final EntityLinkType sourceType;
  final int sourceId;
  final String sourceLabel;
  final void Function(EntityLinkType type, int id, String label) onLinkAdded;

  @override
  State<_AddLinkSheet> createState() => _AddLinkSheetState();
}

class _AddLinkSheetState extends State<_AddLinkSheet> {
  EntityLinkType _selectedType = EntityLinkType.client;
  final _idCtrl = TextEditingController();
  final _labelCtrl = TextEditingController();
  final _relationCtrl = TextEditingController();

  static const _linkableTypes = [
    EntityLinkType.client,
    EntityLinkType.project,
    EntityLinkType.employee,
    EntityLinkType.invoice,
    EntityLinkType.followup,
    EntityLinkType.meeting,
    EntityLinkType.contact,
    EntityLinkType.document,
    EntityLinkType.other,
  ];

  @override
  void dispose() {
    _idCtrl.dispose();
    _labelCtrl.dispose();
    _relationCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;
    final textPrimary = isDark ? NeuColors.textPrimaryDark : NeuColors.textPrimary;
    final surface = isDark ? NeuColors.surfaceDark : NeuColors.surface;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Padding(
        padding: EdgeInsets.only(
          top: 20, left: 20, right: 20,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
            Center(child: Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[700] : Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            )),
            const SizedBox(height: 16),

            Text('إضافة ارتباط جديد',
                style: AppTypography.h3.copyWith(color: textPrimary)),
            const SizedBox(height: 16),

            // Type selector
            Text('نوع الكيان المرتبط',
                style: AppTypography.label.copyWith(color: textPrimary)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8, runSpacing: 8,
              children: _linkableTypes.map((t) {
                final sel = _selectedType == t;
                return GestureDetector(
                  onTap: () => setState(() => _selectedType = t),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                    decoration: BoxDecoration(
                      color: sel ? t.color : surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: sel ? t.color : t.color.withValues(alpha: 0.3)),
                    ),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Icon(t.icon, size: 14,
                          color: sel ? Colors.white : t.color),
                      const SizedBox(width: 5),
                      Text(t.label,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: sel ? FontWeight.w700 : FontWeight.w500,
                            color: sel ? Colors.white : t.color,
                            fontFamily: 'Panorama',
                          )),
                    ]),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 14),

            // Label field
            TextField(
              controller: _labelCtrl,
              textDirection: TextDirection.rtl,
              style: AppTypography.body.copyWith(color: textPrimary),
              decoration: InputDecoration(
                labelText: 'اسم / وصف الكيان',
                labelStyle: TextStyle(color: _selectedType.color),
                prefixIcon: Icon(_selectedType.icon, color: _selectedType.color, size: 20),
                filled: true,
                fillColor: surface,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: _selectedType.color, width: 1.5)),
              ),
            ),
            const SizedBox(height: 10),

            // Relation description
            TextField(
              controller: _relationCtrl,
              textDirection: TextDirection.rtl,
              style: AppTypography.body.copyWith(color: textPrimary),
              decoration: InputDecoration(
                labelText: 'طبيعة العلاقة (اختياري)',
                labelStyle: TextStyle(
                    color: isDark ? NeuColors.textHintDark : NeuColors.textHint),
                prefixIcon: const Icon(Icons.info_outline_rounded, size: 20),
                filled: true,
                fillColor: surface,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 20),

            // Save button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  final label = _labelCtrl.text.trim();
                  if (label.isEmpty) return;
                  widget.onLinkAdded(
                    _selectedType,
                    DateTime.now().millisecondsSinceEpoch, // temporary ID
                    label,
                  );
                },
                icon: const Icon(Icons.add_link_rounded, color: Colors.white),
                label: const Text('إضافة الارتباط',
                    style: TextStyle(color: Colors.white, fontFamily: 'Panorama')),
                style: ElevatedButton.styleFrom(
                  backgroundColor: NeuColors.navyDeep,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}