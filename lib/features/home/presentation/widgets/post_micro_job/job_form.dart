import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:global_earn/shared/widgets/app_text_field.dart';
import 'package:global_earn/features/home/presentation/bloc/post_job_bloc.dart';
import 'package:global_earn/features/home/presentation/bloc/post_job_event.dart';

class JobForm extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController descController;
  final TextEditingController linkController;
  final TextEditingController amountController;
  final TextEditingController limitController;

  const JobForm({
    super.key,
    required this.nameController,
    required this.descController,
    required this.linkController,
    required this.amountController,
    required this.limitController,
  });

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<PostJobBloc>();

    return Column(
      children: [
        AppTextField(
          hint: 'Job Name*',
          icon: Icons.work_outline,
          controller: nameController,
          onChanged: (v) => bloc.add(PostJobFormChanged(jobName: v)),
        ),
        const SizedBox(height: 16),
        AppTextField(
          hint: 'Job Description*',
          icon: Icons.description_outlined,
          controller: descController,
          keyboardType: TextInputType.multiline,
          onChanged: (v) => bloc.add(PostJobFormChanged(jobDescription: v)),
        ),
        const SizedBox(height: 16),
        AppTextField(
          hint: 'Job Link*',
          icon: Icons.link,
          controller: linkController,
          keyboardType: TextInputType.url,
          onChanged: (v) => bloc.add(PostJobFormChanged(jobLink: v)),
        ),
        const SizedBox(height: 16),
        AppTextField(
          hint: 'Per Job Amount*',
          icon: Icons.payments_outlined,
          controller: amountController,
          keyboardType: TextInputType.number,
          onChanged: (v) => bloc.add(PostJobFormChanged(perJobAmount: v)),
        ),
        const SizedBox(height: 16),
        AppTextField(
          hint: 'Total Job Limit*',
          icon: Icons.group_outlined,
          controller: limitController,
          keyboardType: TextInputType.number,
          onChanged: (v) => bloc.add(PostJobFormChanged(totalJobLimit: v)),
        ),

        // Row(
        //   children: [
        //     Expanded(
        //       child: AppTextField(
        //         hint: 'Per Job Amount*',
        //         icon: Icons.payments_outlined,
        //         controller: amountController,
        //         keyboardType: TextInputType.number,
        //         onChanged: (v) => bloc.add(PostJobFormChanged(perJobAmount: v)),
        //       ),
        //     ),
        //     const SizedBox(width: 16),
        //     Expanded(
        //       child: AppTextField(
        //         hint: 'Total Job Limit*',
        //         icon: Icons.group_outlined,
        //         controller: limitController,
        //         keyboardType: TextInputType.number,
        //         onChanged: (v) => bloc.add(PostJobFormChanged(totalJobLimit: v)),
        //       ),
        //     ),
        //   ],
        // ),
      ],
    );
  }
}
