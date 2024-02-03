import 'package:after_layout/after_layout.dart';
import 'package:fast_app_base/common/common.dart';
import 'package:fast_app_base/common/dart/extension/datetime_extension.dart';
import 'package:fast_app_base/common/util/app_keyboard_util.dart';
import 'package:fast_app_base/common/widget/rounded_container.dart';
import 'package:fast_app_base/common/widget/scaffold/bottom_dialog_scaffold.dart';
import 'package:fast_app_base/common/widget/w_round_button.dart';
import 'package:fast_app_base/data/memory/vo/vo_todo.dart';
import 'package:fast_app_base/screen/main/write/vo_write_todo.dart';
import 'package:flutter/material.dart';
import 'package:nav/dialog/dialog.dart';

class WriteTodoDialog extends DialogWidget<WriteTodoResult> {

  final Todo? todoForEdit;

  WriteTodoDialog({super.key, this.todoForEdit});

  @override
  DialogState<WriteTodoDialog> createState() => _WriteTodoDialogState();
}

class _WriteTodoDialogState extends DialogState<WriteTodoDialog>
    with AfterLayoutMixin {
  DateTime _selectedDate = DateTime.now();
  final textEditingController = TextEditingController();

  final node = FocusNode();

  get isEditMode => widget.todoForEdit != null;

  @override
  void initState() {
    if(isEditMode){
      _selectedDate = widget.todoForEdit!.dueDtm;
      textEditingController.text = widget.todoForEdit!.title;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BottomDialogScaffold(
        body: RoundedContainer(
      color: context.backgroundColor,
      child: Column(
        children: [
          Row(
            children: [
              '할일을 작성해주세요'.text.bold.make(),
              spacer,
              _selectedDate.formattedDate.text.make(),
              IconButton(
                icon: const Icon(Icons.calendar_month),
                onPressed: _selectDate,
              ),
            ],
          ),
          h20,
          Row(
            children: [
              Expanded(
                child: TextField(
                  focusNode: node,
                  controller: textEditingController,
                ),
              ),
              RoundButton(
                  text: isEditMode? "수정":"추가",
                  onTap: () {
                    widget.hide(WriteTodoResult(
                      _selectedDate,
                      textEditingController.text,
                    ));
                  }),
            ],
          )
        ],
      ),
    ));
  }

  void _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    if (date != null) {
      setState(() {
        _selectedDate = date;
      });
    }
  }

  @override
  FutureOr<void> afterFirstLayout(BuildContext context) {
    AppKeyboardUtil.show(context, node);
  }
}
