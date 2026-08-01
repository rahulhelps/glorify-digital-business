import 'dart:io';
import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:global_earn/core/constants/app_colors.dart';
import 'package:global_earn/features/user/presentation/bloc/user_bloc.dart';
import 'package:global_earn/features/user/presentation/bloc/user_state.dart';
import 'package:global_earn/features/home/presentation/bloc/post_job_bloc.dart';
import 'package:global_earn/features/home/presentation/bloc/post_job_event.dart';
import 'package:global_earn/features/home/presentation/bloc/post_job_state.dart';
import 'package:global_earn/shared/widgets/verification_guard.dart';

class PostMicroJobScreen extends StatefulWidget {
  const PostMicroJobScreen({super.key});

  @override
  State<PostMicroJobScreen> createState() => _PostMicroJobScreenState();
}

class _PostMicroJobScreenState extends State<PostMicroJobScreen> {
  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final descController = TextEditingController();
  final linkController = TextEditingController();
  final amountController = TextEditingController();
  final limitController = TextEditingController();

  double _totalCost = 0.0;

  @override
  void initState() {
    super.initState();
    amountController.addListener(_calculateTotal);
    limitController.addListener(_calculateTotal);
    
    // Add listeners to update the bloc state on form change so that validation works if needed
    nameController.addListener(_onFormChanged);
    descController.addListener(_onFormChanged);
    linkController.addListener(_onFormChanged);
    amountController.addListener(_onFormChanged);
    limitController.addListener(_onFormChanged);
  }

  void _calculateTotal() {
    final workers = int.tryParse(limitController.text.trim()) ?? 0;
    final pay = double.tryParse(amountController.text.trim()) ?? 0.0;
    setState(() {
      _totalCost = workers * pay;
    });
  }

  void _onFormChanged() {
    context.read<PostJobBloc>().add(
      PostJobFormChanged(
        jobName: nameController.text.trim(),
        jobDescription: descController.text.trim(),
        jobLink: linkController.text.trim(),
        perJobAmount: amountController.text.trim(),
        totalJobLimit: limitController.text.trim(),
      ),
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    descController.dispose();
    linkController.dispose();
    amountController.dispose();
    limitController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final picker = ImagePicker();
      final image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1080,
        maxHeight: 1080,
        imageQuality: 85,
      );
      if (image != null && mounted) {
        context.read<PostJobBloc>().add(PostJobImagePicked(File(image.path)));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('ছবি নির্বাচন করতে সমস্যা হয়েছে'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _submitJob(double userBalance) {
    if (_formKey.currentState?.validate() ?? false) {
      final blocState = context.read<PostJobBloc>().state;
      if (blocState.image == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('অনুগ্রহ করে একটি ছবি নির্বাচন করুন'),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }
      if (_totalCost > userBalance) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Insufficient balance'),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }
      context.read<PostJobBloc>().add(const PostJobSubmitted());
    }
  }

  @override
  Widget build(BuildContext context) {
    return VerificationGuard(
      child: Scaffold(
        backgroundColor: const Color(0xFFF4F6F9),
        body: BlocConsumer<PostJobBloc, PostJobState>(
          listener: (context, state) {
            if (state is PostJobSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Job posted successfully and is pending approval'),
                  backgroundColor: AppColors.success,
                ),
              );
              context.pop();
            } else if (state is PostJobFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: AppColors.error,
                ),
              );
            }
          },
          builder: (context, postJobState) {
            final isLoading = postJobState is PostJobLoading;
            
            return BlocBuilder<UserBloc, UserState>(
              builder: (context, userState) {
                double balance = 0.0;
                if (userState is UserLoaded) {
                  balance = userState.user.withdrawableBalance;
                }

                return CustomScrollView(
                  slivers: [
                    // 1. Premium Header Card - Updated as per FinTech Aesthetic
                    _buildHeader(context, balance),

                    // 2. Navigation Tabs
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                        child: Row(
                          children: [
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: AppColors.primary, width: 1.5),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.primary.withValues(alpha: 0.1),
                                      blurRadius: 8,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.add_circle_outline, color: AppColors.primary, size: 18),
                                    const SizedBox(width: 8),
                                    Text(
                                      'নতুন জব তৈরি করুন',
                                      style: GoogleFonts.manrope(
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: GestureDetector(
                                onTap: () => context.push('/home/job-approval'),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade100,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: Colors.grey.shade300),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.history, color: Colors.grey.shade600, size: 18),
                                      const SizedBox(width: 8),
                                      Text(
                                        'আমার পোস্ট করা জব',
                                        style: GoogleFonts.manrope(
                                          color: Colors.grey.shade700,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // 3. Form Body
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        child: Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.04),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildSectionTitle('জবের শিরোনাম (Job Title) *'),
                                _buildTextField(
                                  controller: nameController,
                                  hint: 'যেমন: ইউটিউব চ্যানেল সাবস্ক্রাইব',
                                  enabled: !isLoading,
                                  validator: (v) => v!.isEmpty ? 'শিরোনাম আবশ্যক' : null,
                                ),
                                const SizedBox(height: 20),

                                _buildSectionTitle('কাজের বিবরণ ও নিয়মাবলি (Description) *'),
                                _buildTextField(
                                  controller: descController,
                                  hint: 'ওয়ার্কারকে কী কী করতে হবে তা বিস্তারিত লিখুন...',
                                  maxLines: 4,
                                  enabled: !isLoading,
                                  validator: (v) => v!.isEmpty ? 'বিবরণ আবশ্যক' : null,
                                ),
                                const SizedBox(height: 20),

                                _buildSectionTitle('প্রুফ বা প্রমাণের বর্ণনা (Required Proof) *'),
                                _buildTextField(
                                  controller: linkController,
                                  hint: 'এইখানে কাজের লিংক দিন',
                                  maxLines: 2,
                                  enabled: !isLoading,
                                  validator: (v) => v!.isEmpty ? 'প্রুফ আবশ্যক' : null,
                                ),
                                const SizedBox(height: 24),

                                // Feature Image Upload (NEW)
                                _buildSectionTitle('Feature Image (1টি ছবি নির্বাচন করুন) *'),
                                const SizedBox(height: 8),
                                _buildImagePicker(postJobState.image, isLoading),
                                const SizedBox(height: 24),

                                Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          _buildSectionTitle('ওয়ার্কার সংখ্যা *'),
                                          _buildTextField(
                                            controller: limitController,
                                            hint: 'জন',
                                            keyboardType: TextInputType.number,
                                            enabled: !isLoading,
                                            validator: (v) => v!.isEmpty ? 'আবশ্যক' : null,
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          _buildSectionTitle('ওয়ার্কার প্রতি পে *'),
                                          _buildTextField(
                                            controller: amountController,
                                            hint: '৳',
                                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                            enabled: !isLoading,
                                            validator: (v) => v!.isEmpty ? 'আবশ্যক' : null,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 32),

                                // Budget Calculation Box
                                _buildBudgetCalculationBox(balance),
                                const SizedBox(height: 32),

                                // Submit Button
                                SizedBox(
                                  width: double.infinity,
                                  height: 56,
                                  child: ElevatedButton(
                                    onPressed: isLoading ? null : () => _submitJob(balance),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.primary,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      elevation: 0,
                                    ),
                                    child: isLoading
                                        ? const SizedBox(
                                            width: 24,
                                            height: 24,
                                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                                          )
                                        : Text(
                                            'জব পোস্ট করুন',
                                            style: GoogleFonts.manrope(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SliverToBoxAdapter(child: SizedBox(height: 40)),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, double balance) {
    return SliverAppBar(
      expandedHeight: 230,
      pinned: true,
      elevation: 0,
      backgroundColor: AppColors.primary,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
        onPressed: () => context.pop(),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.history, color: Colors.white),
          onPressed: () => context.push('/home/my-posted-jobs-history'),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.primary, AppColors.cyan],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 48, 20, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.work_outline_rounded, color: Colors.amber, size: 24),
                      const SizedBox(width: 8),
                      Text(
                        'Micro Job Post',
                        style: GoogleFonts.manrope(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'সহজে কাজ পোস্ট করে হাজারো একটিভ ওয়ার্কারের মাধ্যমে আপনার প্রয়োজনীয় টাস্ক সম্পন্ন করে নিন।',
                    style: GoogleFonts.manrope(
                      fontSize: 12,
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.amber.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.account_balance_wallet_rounded, color: Colors.amber, size: 18),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              children: [
                                Text(
                                  'বর্তমান ওয়ালেট ব্যালেন্স',
                                  style: GoogleFonts.manrope(
                                    fontSize: 11,
                                    color: Colors.white70,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                InkWell(
                                  onTap: () {
                                    // Trigger your refresh logic here
                                    // e.g., context.read<AuthBloc>().add(FetchUserEvent());
                                  },
                                  borderRadius: BorderRadius.circular(12),
                                  child: const Padding(
                                    padding: EdgeInsets.all(4.0),
                                    child: Icon(Icons.refresh_rounded, color: Colors.white70, size: 14),
                                  ),
                                ),
                              ],
                            ),
                            BlocBuilder<UserBloc, UserState>(
                              builder: (context, userState) {
                                double currentBalance = 0.0;
                                if (userState is UserLoaded) {
                                  currentBalance = userState.user.withdrawableBalance;
                                }
                                return Text(
                                  '৳${currentBalance.toStringAsFixed(2)} BDT',
                                  style: GoogleFonts.manrope(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.amber,
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: GoogleFonts.manrope(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Colors.grey.shade700,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    bool enabled = true,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
      style: GoogleFonts.manrope(fontSize: 14, color: Colors.black87),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.manrope(color: Colors.grey.shade400, fontSize: 13),
        filled: true,
        fillColor: Colors.grey.shade50,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 2.0),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error),
        ),
      ),
    );
  }

  Widget _buildImagePicker(File? image, bool isLoading) {
    return GestureDetector(
      onTap: isLoading ? null : _pickImage,
      child: Container(
        height: 140,
        width: double.infinity,
        decoration: BoxDecoration(
          color: image == null ? AppColors.primary.withValues(alpha: 0.05) : Colors.black12,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: image == null ? AppColors.primary.withValues(alpha: 0.3) : Colors.transparent,
            style: image == null ? BorderStyle.solid : BorderStyle.none,
          ),
          image: image != null
              ? DecorationImage(
                  image: FileImage(image),
                  fit: BoxFit.cover,
                )
              : null,
        ),
        child: image == null
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.add_photo_alternate_outlined, color: AppColors.primary, size: 28),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'ক্লিক করে ছবি আপলোড করুন',
                    style: GoogleFonts.manrope(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ],
              )
            : Stack(
                children: [
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: isLoading
                          ? null
                          : () => context.read<PostJobBloc>().add(const PostJobImagePicked(null)),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Icon(Icons.close, color: Colors.white, size: 16),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildBudgetCalculationBox(double userBalance) {
    final bool isSufficient = _totalCost <= userBalance;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'মোট সার্ভিস খরচ:',
                style: GoogleFonts.manrope(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade700,
                ),
              ),
              Text(
                '৳${_totalCost.toStringAsFixed(2)}',
                style: GoogleFonts.manrope(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                isSufficient ? Icons.check_circle_outline : Icons.error_outline,
                size: 16,
                color: isSufficient ? Colors.green.shade700 : AppColors.error,
              ),
              const SizedBox(width: 6),
              Text(
                isSufficient
                    ? 'আপনার ওয়ালেটে পর্যাপ্ত ব্যালেন্স আছে।'
                    : 'পর্যাপ্ত ব্যালেন্স নেই। আরও ৳${(_totalCost - userBalance).toStringAsFixed(2)} প্রয়োজন।',
                style: GoogleFonts.manrope(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isSufficient ? Colors.green.shade700 : AppColors.error,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
