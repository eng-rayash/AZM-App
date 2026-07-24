import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import 'package:hijri/hijri_calendar.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/neu_colors.dart';
import '../../../core/theme/neu_decorations.dart';
import '../../../core/services/file_storage_service.dart';
import '../../../shared/widgets/neu_button.dart';
import '../../../shared/widgets/neu_card.dart';
import '../../../shared/widgets/neu_input.dart';
import '../domain/archive_repository.dart';
import '../providers/archive_categories_provider.dart';
import '../../../core/services/document_scanner_service.dart';
import '../../../core/database/providers/database_providers.dart';
import '../../../core/security/secure_storage_service.dart';

/// Professional Executive screen for creating a new official Memo.
/// Includes camera scanner, auto Hijri/Gregorian date formatting,
/// and automated high-quality scanned PDF generation.
class CreateArchiveScreen extends ConsumerStatefulWidget {
  const CreateArchiveScreen({super.key, this.archiveId});

  final int? archiveId;

  @override
  ConsumerState<CreateArchiveScreen> createState() =>
      _CreateArchiveScreenState();
}

class _CreateArchiveScreenState extends ConsumerState<CreateArchiveScreen> {
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    if (widget.archiveId != null) {
      _loadArchiveData();
    }
  }

  Future<void> _loadArchiveData() async {
    final db = ref.read(databaseProvider);
    final doc = await db.archiveDao.getById(widget.archiveId!);
    if (doc != null) {
      setState(() {
        _titleController.text = doc.title;
        _refNumberController.text = doc.referenceNumber ?? '';
        _categoryController.text = doc.category ?? '';
        _directedEntityController.text = doc.directedEntity ?? '';
        _notesController.text = doc.notes ?? '';
        _isConfidential = doc.isConfidential;
        
        if (doc.documentDate != null) {
          _gregorianDateStr = doc.documentDate;
          _selectedDate = DateTime.tryParse(doc.documentDate!);
        }
        _hijriDateStr = doc.hijriDate;
        if (_gregorianDateStr != null && _hijriDateStr != null) {
          _dateController.text = '$_gregorianDateStr م  |  $_hijriDateStr هـ';
        }
        
        if (doc.localFilePath != null && doc.localFilePath!.isNotEmpty) {
          _pickedDocument = File(doc.localFilePath!);
        }
      });
    }
  }

  // Controllers
  final _titleController = TextEditingController();
  final _refNumberController = TextEditingController();
  final _dateController =
      TextEditingController(); // Gregorian and Hijri summary text
  final _directedEntityController = TextEditingController();
  final _notesController = TextEditingController();
  final _categoryController = TextEditingController();

  // Selected State
  DateTime? _selectedDate;
  String? _gregorianDateStr;
  String? _hijriDateStr;

  bool _isConfidential = false;
  bool _isLoading = false;

  // Scanner State
  final List<File> _capturedImages = [];
  File? _pickedDocument;
  final _picker = ImagePicker();

  @override
  void dispose() {
    _titleController.dispose();
    _refNumberController.dispose();
    _dateController.dispose();
    _directedEntityController.dispose();
    _notesController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  // --- Date Picking & Hijri Conversion ---
  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      locale: const Locale('ar'),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: NeuColors.navyDeep,
              onPrimary: Colors.white,
              onSurface: NeuColors.navyDeep,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      // Setup Hijri Locale to Arabic
      HijriCalendar.setLocal('ar');
      final hijri = HijriCalendar.fromDate(picked);

      setState(() {
        _selectedDate = picked;
        _gregorianDateStr = DateFormat('yyyy-MM-dd').format(picked);

        // Custom elegant Hijri representation: e.g., "15 ربيع الثاني 1445"
        _hijriDateStr = '${hijri.hDay} ${hijri.longMonthName} ${hijri.hYear}';

        _dateController.text = '$_gregorianDateStr م  |  $_hijriDateStr هـ';
      });
    }
  }

  // --- Image Pickers & Filters ---
  Future<File?> _showFilterDialog(File croppedFile) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scannerService = DocumentScannerService();
    
    // Asynchronously load the last used filter from secure storage
    final savedFilterName = await SecureStorageService.instance.read('last_used_filter');
    DocumentFilter selectedFilter = DocumentFilter.fidelityColor;
    if (savedFilterName != null) {
      selectedFilter = DocumentFilter.values.firstWhere(
        (f) => f.name == savedFilterName,
        orElse: () => DocumentFilter.fidelityColor,
      );
    }
    double filterIntensity = 1.0;
    
    if (!mounted) return null;
    
    return await showModalBottomSheet<File>(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? NeuColors.bgColorDark : NeuColors.bgColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: const EdgeInsets.all(20),
              height: MediaQuery.of(context).size.height * 0.8,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'تطبيق فلتر المستند',
                    style: (isDark ? AppTypography.h3Dark : AppTypography.h3).copyWith(fontSize: 18),
                    textAlign: TextAlign.center,
                  ),
                  AppSpacing.gapMd,
                  Expanded(
                    child: Center(
                      child: FutureBuilder<File?>(
                        future: scannerService.applyFilter(croppedFile, selectedFilter, filterIntensity),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const CircularProgressIndicator(color: NeuColors.navyMid);
                          }
                          if (snapshot.hasData && snapshot.data != null) {
                            return ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Image.file(
                                snapshot.data!,
                                fit: BoxFit.contain,
                              ),
                            );
                          }
                          return Image.file(croppedFile, fit: BoxFit.contain);
                        },
                      ),
                    ),
                  ),
                  AppSpacing.gapLg,
                  
                  // Intensity Slider Block
                  if (selectedFilter != DocumentFilter.original) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          Text(
                            'شدة الفلتر: ',
                            style: (isDark ? AppTypography.captionDark : AppTypography.caption).copyWith(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            '${(filterIntensity * 100).round()}%',
                            style: (isDark ? AppTypography.captionDark : AppTypography.caption).copyWith(
                              color: isDark ? NeuColors.goldAccent : NeuColors.navyDeep,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: SliderTheme(
                        data: SliderThemeData(
                          activeTrackColor: isDark ? NeuColors.goldAccent : NeuColors.navyDeep,
                          inactiveTrackColor: isDark ? NeuColors.dividerDark : NeuColors.divider,
                          thumbColor: isDark ? NeuColors.goldAccent : NeuColors.navyDeep,
                          overlayColor: (isDark ? NeuColors.goldAccent : NeuColors.navyDeep).withValues(alpha: 0.12),
                          valueIndicatorColor: isDark ? NeuColors.goldAccent : NeuColors.navyDeep,
                        ),
                        child: Slider(
                          value: filterIntensity,
                          min: 0.0,
                          max: 1.0,
                          onChanged: (value) {
                            setModalState(() {
                              filterIntensity = value;
                            });
                          },
                        ),
                      ),
                    ),
                    AppSpacing.gapMd,
                  ],

                  Text(
                    'اختر الفلتر المناسب لوضوح الورقة:',
                    style: isDark ? AppTypography.captionDark : AppTypography.caption,
                    textAlign: TextAlign.center,
                  ),
                  AppSpacing.gapSm,
                  
                  // Clean, symmetric vertical scroll list of filter rows
                  SizedBox(
                    height: 140,
                    child: ListView(
                      physics: const ClampingScrollPhysics(),
                      children: DocumentFilter.values.map((filter) {
                        final isSelected = filter == selectedFilter;
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 2.0),
                          child: GestureDetector(
                            onTap: () {
                              setModalState(() {
                                selectedFilter = filter;
                              });
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 150),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                              decoration: isSelected
                                  ? NeuDecorations.neuPressed(radius: 12, isDark: isDark)
                                  : NeuDecorations.neuFlatSoft(radius: 12, isDark: isDark),
                              child: Row(
                                children: [
                                  Icon(
                                    filter.icon,
                                    color: isSelected
                                        ? (isDark ? NeuColors.goldAccent : NeuColors.navyDeep)
                                        : (isDark ? NeuColors.textSecondaryDark : NeuColors.textSecondary),
                                    size: 20,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      filter.arabicLabel,
                                      style: (isDark ? AppTypography.bodyDark : AppTypography.body).copyWith(
                                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                        fontSize: 12,
                                        color: isSelected
                                            ? (isDark ? NeuColors.goldAccent : NeuColors.navyDeep)
                                            : null,
                                      ),
                                    ),
                                  ),
                                  if (isSelected)
                                    Icon(
                                      Icons.check_circle_rounded,
                                      color: isDark ? NeuColors.goldAccent : NeuColors.navyDeep,
                                      size: 18,
                                    ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  AppSpacing.gapLg,
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context, null),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: isDark ? NeuColors.goldAccent : NeuColors.navyDeep,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text('إلغاء'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () async {
                            // Persist the chosen filter for the next launch
                            await SecureStorageService.instance.write('last_used_filter', selectedFilter.name);
                            final resultFile = await scannerService.applyFilter(croppedFile, selectedFilter, filterIntensity);
                            if (context.mounted) {
                              Navigator.pop(context, resultFile);
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isDark ? NeuColors.goldAccent : NeuColors.navyDeep,
                            foregroundColor: isDark ? NeuColors.bgColorDark : Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text('تطبيق'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _captureWithCamera() async {
    try {
      final image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 100,
        maxWidth: 2400,
        maxHeight: 2400,
      );
      if (image != null && mounted) {
        final cropped = await DocumentScannerService().cropImage(context, File(image.path));
        if (cropped != null) {
          final filtered = await _showFilterDialog(cropped);
          if (filtered != null && mounted) {
            setState(() {
              _capturedImages.add(filtered);
              _pickedDocument = null; // Clear picked document if images are used
            });
          }
        }
      }
    } catch (e) {
      _showSnackBar('خطأ أثناء التقاط الصورة: $e');
    }
  }

  Future<void> _selectFromGallery() async {
    try {
      final images = await _picker.pickMultiImage(
        imageQuality: 100,
        maxWidth: 2400,
        maxHeight: 2400,
      );
      if (images.isNotEmpty) {
        for (final xfile in images) {
          if (!mounted) break;
          final cropped = await DocumentScannerService().cropImage(context, File(xfile.path));
          if (cropped != null) {
            final filtered = await _showFilterDialog(cropped);
            if (filtered != null && mounted) {
              setState(() {
                _capturedImages.add(filtered);
                _pickedDocument = null; // Clear picked document if images are used
              });
            }
          }
        }
      }
    } catch (e) {
      _showSnackBar('خطأ أثناء اختيار الصور: $e');
    }
  }

  Future<void> _pickDocument() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx'],
      );

      if (result != null && result.files.single.path != null) {
        setState(() {
          _pickedDocument = File(result.files.single.path!);
          _capturedImages.clear(); // Clear images if a document is picked
        });
      }
    } catch (e) {
      if (mounted) _showSnackBar('تعذر اختيار الملف');
    }
  }

  void _removeCapturedImage(int index) {
    setState(() {
      _capturedImages.removeAt(index);
    });
  }

  // --- PDF Generation ---
  Future<String?> _generateOrCopyDocument() async {
    final String titleStr = _titleController.text.trim();
    final String refStr = _refNumberController.text.trim();

    // Use FileStorageService for consistent filename generation and storage
    final fileStorage = FileStorageService();

    if (_pickedDocument != null) {
      // If the file is already in the application documents/archive folder, don't copy it onto itself
      final docDir = await getApplicationDocumentsDirectory();
      if (_pickedDocument!.path.startsWith(docDir.path)) {
        return _pickedDocument!.path;
      }

      final ext = _pickedDocument!.path.split('.').last;
      final filename = FileStorageService.generateFileName(
        title: titleStr,
        referenceNumber: refStr,
        extension: ext,
      );

      return await fileStorage.saveFile(
        sourceFile: _pickedDocument!,
        filename: filename,
      );
    }

    if (_capturedImages.isEmpty) return null;

    final pdf = pw.Document();

    for (final file in _capturedImages) {
      pw.ImageProvider pdfImage;
      try {
        // Use flutterImageProvider to safely decode all image formats (e.g. HEIC) and apply EXIF rotation
        pdfImage = await flutterImageProvider(FileImage(file));
      } catch (e) {
        // Fallback to direct file bytes using pw.MemoryImage if flutterImageProvider fails
        final bytes = await file.readAsBytes();
        pdfImage = pw.MemoryImage(bytes);
      }

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: pw.EdgeInsets.zero, // scanner/full-bleed look
          build: (pw.Context context) {
            return pw.Center(child: pw.Image(pdfImage, fit: pw.BoxFit.contain));
          },
        ),
      );
    }

    // Generate PDF with organized filename
    final filename = FileStorageService.generateFileName(
      title: titleStr,
      referenceNumber: refStr,
      extension: 'pdf',
    );

    final tempPdf = File(
      '${(await getApplicationDocumentsDirectory()).path}/temp_$filename',
    );
    await tempPdf.writeAsBytes(await pdf.save());

    // Save to archive using FileStorageService
    final savedPath = await fileStorage.saveFile(
      sourceFile: tempPdf,
      filename: filename,
    );

    // Clean up temporary file
    await tempPdf.delete().catchError((_) => tempPdf);

    return savedPath;
  }

  void _showSnackBar(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text, textDirection: TextDirection.rtl),
        backgroundColor: NeuColors.navyDeep,
      ),
    );
  }

  // --- Form Submission ---
  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final finalCategory = _categoryController.text.trim();

      if (finalCategory.isEmpty) {
        _showSnackBar('يرجى تحديد أو كتابة نوع المذكرة');
        setState(() => _isLoading = false);
        return;
      }

      // Automatically save custom memo type to persisted suggestions
      await ref
          .read(archiveCategoriesProvider.notifier)
          .addCategory(finalCategory);

      // Compile images into a high-quality PDF or copy picked document
      String? localPdfPath = _pickedDocument?.path;
      if (_capturedImages.isNotEmpty) {
        localPdfPath = await _generateOrCopyDocument();
      } else if (_pickedDocument != null) {
        localPdfPath = await _generateOrCopyDocument();
      }

      final repository = ref.read(archiveRepositoryProvider);
      if (widget.archiveId != null) {
        await repository.updateArchiveRecord(
          id: widget.archiveId!,
          title: _titleController.text.trim(),
          referenceNumber: _refNumberController.text.trim(),
          documentDate: _gregorianDateStr,
          hijriDate: _hijriDateStr,
          directedEntity: _directedEntityController.text.trim(),
          category: finalCategory,
          localFilePath: localPdfPath,
          tags: '',
          notes: _notesController.text.trim(),
          isConfidential: _isConfidential,
        );
      } else {
        await repository.createArchiveRecord(
          title: _titleController.text.trim(),
          referenceNumber: _refNumberController.text.trim(),
          documentDate: _gregorianDateStr,
          hijriDate: _hijriDateStr,
          directedEntity: _directedEntityController.text.trim(),
          category: finalCategory,
          localFilePath: localPdfPath,
          tags: '',
          notes: _notesController.text.trim(),
          isConfidential: _isConfidential,
        );
      }

      if (mounted) {
        _showSnackBar(widget.archiveId != null ? 'تم تعديل المذكرة مؤرشفة بنجاح' : 'تم حفظ وأرشفة المذكرة الرسمية بنجاح');
        context.pop(true); // Return success to trigger list refresh
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('حدث خطأ أثناء أرشفة المذكرة: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? NeuColors.bgColorDark : NeuColors.bgColor,
      appBar: AppBar(
        backgroundColor: isDark ? NeuColors.bgColorDark : NeuColors.bgColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.close_rounded,
            color: isDark ? NeuColors.textPrimaryDark : NeuColors.textPrimary,
          ),
          onPressed: () => context.pop(),
        ),
        title: Text(
          widget.archiveId != null ? 'تعديل المذكرة مؤرشفة' : 'أرشفة مذكرة رسمية جديدة',
          style: isDark ? AppTypography.h3Dark : AppTypography.h3,
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: Form(
            key: _formKey,
            child: ListView(
              padding: AppSpacing.screen,
              children: [
                // 1. Memo Subject (Title)
                NeuInput(
                  controller: _titleController,
                  label: 'موضوع المذكرة *',
                  hint: 'أدخل موضوع أو عنوان المذكرة التفصيلي',
                  prefixIcon: Icons.subtitles_rounded,
                  validator: (val) => val == null || val.trim().isEmpty
                      ? 'هذا الحقل مطلوب'
                      : null,
                ),
                AppSpacing.gapLg,

                // 2. Memo Type (Manual entry with suggestion chips)
                NeuInput(
                  controller: _categoryController,
                  label: 'نوع المذكرة *',
                  hint: 'اكتب نوع المذكرة (مثال: خطاب، تعميم، قرار...)',
                  prefixIcon: Icons.edit_note_rounded,
                  validator: (val) => val == null || val.trim().isEmpty
                      ? 'يرجى تحديد أو كتابة نوع المذكرة'
                      : null,
                ),
                AppSpacing.gapSm,
                Text(
                  'اختر من القائمة أو أضف نوعاً جديداً. اضغط مطولاً على أي نوع لحذفه.',
                  style: isDark
                      ? AppTypography.captionDark
                      : AppTypography.caption,
                ),
                AppSpacing.gapSm,
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: (ref.watch(archiveCategoriesProvider).value ?? []).map((
                    type,
                  ) {
                    final isSelected = _categoryController.text.trim() == type;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _categoryController.text = type;
                        });
                      },
                      onLongPress: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            backgroundColor: isDark
                                ? NeuColors.bgColorDark
                                : NeuColors.bgColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            title: Text(
                              'حذف نوع المذكرة',
                              style: isDark
                                  ? AppTypography.h3Dark
                                  : AppTypography.h3,
                            ),
                            content: Text(
                              'هل تريد إزالة "$type" من قائمة الاقتراحات المحفوظة؟',
                              style: isDark
                                  ? AppTypography.bodyDark
                                  : AppTypography.body,
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(ctx, false),
                                child: Text(
                                  'إلغاء',
                                  style: TextStyle(
                                    color: isDark
                                        ? NeuColors.textSecondaryDark
                                        : NeuColors.textSecondary,
                                  ),
                                ),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(ctx, true),
                                child: const Text(
                                  'حذف',
                                  style: TextStyle(
                                    color: NeuColors.priorityCritical,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                        if (confirm == true) {
                          ref
                              .read(archiveCategoriesProvider.notifier)
                              .removeCategory(type);
                        }
                      },
                      child: AnimatedContainer(
                        duration: NeuDecorations.pressDuration,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        decoration: isSelected
                            ? NeuDecorations.neuPressed(
                                radius: 12,
                                isDark: isDark,
                              )
                            : NeuDecorations.neuFlat(
                                radius: 12,
                                isDark: isDark,
                              ),
                        child: Text(
                          type,
                          style:
                              (isDark
                                      ? AppTypography.captionDark
                                      : AppTypography.caption)
                                  .copyWith(
                                    color: isSelected
                                        ? (isDark
                                              ? NeuColors.goldAccent
                                              : NeuColors.navyDeep)
                                        : (isDark
                                              ? NeuColors.textSecondaryDark
                                              : NeuColors.textSecondary),
                                    fontWeight: isSelected
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                AppSpacing.gapLg,

                // 3. Memo Number (Reference) & Directed Entity (Side by Side / Column)
                Row(
                  children: [
                    Expanded(
                      child: NeuInput(
                        controller: _refNumberController,
                        label: 'رقم المذكرة',
                        hint: 'مثال: م-123-45',
                        prefixIcon: Icons.tag_rounded,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: NeuInput(
                        controller: _directedEntityController,
                        label: 'الجهة الموجهة إليها',
                        hint: 'الوزارة، الإدارة العامة...',
                        prefixIcon: Icons.business_rounded,
                      ),
                    ),
                  ],
                ),
                AppSpacing.gapLg,

                // 4. Integrated Dates Picker
                GestureDetector(
                  onTap: _pickDate,
                  child: AbsorbPointer(
                    child: NeuInput(
                      controller: _dateController,
                      label: 'التاريخ الهجري والميلادي',
                      hint: 'انقر لتحديد تاريخ المذكرة الرسمي',
                      prefixIcon: Icons.calendar_month_rounded,
                    ),
                  ),
                ),
                AppSpacing.gapLg,

                // 5. Notes & Keywords
                NeuInput(
                  controller: _notesController,
                  label: 'الملاحظات / مخرجات المذكرة',
                  hint: 'أدخل أي ملاحظات، قرارات أو مخرجات خاصة بالمذكرة',
                  prefixIcon: Icons.description_rounded,
                  maxLines: 3,
                ),
                AppSpacing.gapXxl,

                // 6. Camera Photo Scanning Section
                NeuCard(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.document_scanner_rounded,
                                  color: NeuColors.navyMid,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'مرفقات المذكرة (PDF ممسوح ضوئياً)',
                                    style: (isDark
                                            ? AppTypography.bodyDark
                                            : AppTypography.body)
                                        .copyWith(fontWeight: FontWeight.bold),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          if (_capturedImages.isNotEmpty)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: NeuColors.navyDeep.withValues(
                                  alpha: 0.1,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                'عدد الصفحات: ${_capturedImages.length}',
                                style: TextStyle(
                                  color: isDark
                                      ? NeuColors.goldAccent
                                      : NeuColors.navyDeep,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'قم بتصوير المذكرة الورقية بواسطة الكاميرا، اختر صوراً، أو أرفق مستنداً جاهزاً (PDF/DOC)، وسيقوم النظام بتسميته تلقائياً باسم ورقم المذكرة وحفظه.',
                        style: isDark
                            ? AppTypography.captionDark
                            : AppTypography.caption,
                      ),
                      const SizedBox(height: 16),
                      if (_pickedDocument != null) ...[
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isDark
                                ? NeuColors.surfaceDark
                                : NeuColors.surface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: NeuColors.navyDeep.withAlpha(50),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.picture_as_pdf_rounded,
                                color: NeuColors.danger,
                                size: 28,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  _pickedDocument!.path
                                      .split(Platform.pathSeparator)
                                      .last,
                                  style: isDark
                                      ? AppTypography.bodyDark
                                      : AppTypography.body,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.close_rounded,
                                  color: NeuColors.danger,
                                ),
                                onPressed: () =>
                                    setState(() => _pickedDocument = null),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: _captureWithCamera,
                              icon: const Icon(Icons.camera_alt_rounded),
                              label: const Text('تصوير بالكاميرا'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: isDark
                                    ? NeuColors.goldAccent
                                    : NeuColors.navyDeep,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                side: BorderSide(
                                  color: isDark
                                      ? NeuColors.goldAccent.withValues(
                                          alpha: 0.5,
                                        )
                                      : NeuColors.navyDeep.withValues(
                                          alpha: 0.5,
                                        ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: _selectFromGallery,
                              icon: const Icon(Icons.photo_library_rounded),
                              label: const Text('المعرض (الألبوم)'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: isDark
                                    ? NeuColors.goldAccent
                                    : NeuColors.navyDeep,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                side: BorderSide(
                                  color: isDark
                                      ? NeuColors.goldAccent.withValues(
                                          alpha: 0.5,
                                        )
                                      : NeuColors.navyDeep.withValues(
                                          alpha: 0.5,
                                        ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: _pickDocument,
                          icon: const Icon(Icons.upload_file_rounded),
                          label: const Text('إرفاق مستند من الهاتف (PDF/DOC)'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: isDark
                                ? NeuColors.goldAccent
                                : NeuColors.navyDeep,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            side: BorderSide(
                              color: isDark
                                  ? NeuColors.goldAccent.withAlpha(128)
                                  : NeuColors.navyDeep.withAlpha(128),
                            ),
                          ),
                        ),
                      ),

                      // Thumbnails horizontal list
                      if (_capturedImages.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        SizedBox(
                          height: 130,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: _capturedImages.length,
                            itemBuilder: (context, index) {
                              final file = _capturedImages[index];
                              return Padding(
                                padding: const EdgeInsets.only(left: 12),
                                child: Stack(
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: isDark
                                              ? NeuColors.dividerDark
                                              : NeuColors.divider,
                                          width: 1,
                                        ),
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(11),
                                        child: Image.file(
                                          file,
                                          width: 90,
                                          height: 130,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      top: 4,
                                      right: 4,
                                      child: GestureDetector(
                                        onTap: () =>
                                            _removeCapturedImage(index),
                                        child: Container(
                                          padding: const EdgeInsets.all(4),
                                          decoration: const BoxDecoration(
                                            color: Colors.black87,
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(
                                            Icons.close_rounded,
                                            color: Colors.white,
                                            size: 14,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      bottom: 4,
                                      left: 4,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: NeuColors.navyDeep.withValues(
                                            alpha: 0.8,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            6,
                                          ),
                                        ),
                                        child: Text(
                                          'صفحة ${index + 1}',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 9,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                AppSpacing.gapXxl,

                // 7. Confidential Toggle
                NeuCard(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Icon(
                              Icons.lock_rounded,
                              color: _isConfidential
                                  ? NeuColors.priorityCritical
                                  : NeuColors.textHint,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'مذكرة سريّة للغاية',
                                    style:
                                        (isDark
                                                ? AppTypography.bodyDark
                                                : AppTypography.body)
                                            .copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    'الوصول لهذه المذكرة سيتطلب تسجيل الدخول وسيقيد المعاينة',
                                    style: isDark
                                        ? AppTypography.captionDark
                                        : AppTypography.caption,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Switch.adaptive(
                        value: _isConfidential,
                        onChanged: (val) =>
                            setState(() => _isConfidential = val),
                        activeThumbColor: NeuColors.priorityCritical,
                        activeTrackColor: NeuColors.priorityCritical.withValues(
                          alpha: 0.4,
                        ),
                      ),
                    ],
                  ),
                ),
                AppSpacing.gapXxl,

                // 8. Submit Button
                NeuButton(
                  onPressed: _isLoading ? null : _submit,
                  isLoading: _isLoading,
                  label: widget.archiveId != null ? 'حفظ التعديلات' : 'حفظ المذكرة في الأرشيف',
                  icon: Icons.save_rounded,
                ),
                AppSpacing.gapXxl,
              ],
            ),
          ),
        ),
      ),
    );
  }
}