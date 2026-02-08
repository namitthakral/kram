import 'package:flutter/material.dart';

class AiQuickActions extends StatelessWidget {
  const AiQuickActions({
    required this.role,
    required this.onActionSelected,
    super.key,
  });
  final String role;
  final Function(String) onActionSelected;

  List<String> _getActionsForRole(String role) {
    switch (role.toLowerCase()) {
      case 'student':
        return [
          'What are my next classes?',
          'Show my recent attendance',
          'Do I have any pending assignments?',
          'Summarize my last report card',
        ];
      case 'teacher':
        return [
          'Show list of students in Class A',
          'Which students have low attendance?',
          'Generate a quiz for my next class',
          'Summarize class performance',
        ];
      case 'parent':
        return [
          'How is my child doing?',
          'Show recent exam results',
          'Is my child attending classes?',
          'Any fees pending?',
        ];
      default:
        return ['What can you do?', 'Who am I?'];
    }
  }

  @override
  Widget build(BuildContext context) {
    final actions = _getActionsForRole(role);

    return SizedBox(
      height: 50,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        scrollDirection: Axis.horizontal,
        itemCount: actions.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder:
            (context, index) => ActionChip(
              elevation: 0,
              pressElevation: 2,
              backgroundColor: Theme.of(
                context,
              ).primaryColor.withValues(alpha: 0.1),
              labelStyle: TextStyle(
                color: Theme.of(context).primaryColor,
                fontWeight: FontWeight.w500,
              ),
              label: Text(actions[index]),
              onPressed: () => onActionSelected(actions[index]),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: Theme.of(context).primaryColor.withValues(alpha: 0.2),
                ),
              ),
            ),
      ),
    );
  }
}
