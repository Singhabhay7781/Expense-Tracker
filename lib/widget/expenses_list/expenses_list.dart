import 'package:expense_tracker/models/expense.dart';
import 'package:expense_tracker/provider/expense_provider.dart';
import 'package:expense_tracker/widget/expenses_list/expense_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ExpensesList extends ConsumerWidget {
  const ExpensesList({super.key, required this.expenses});
  final List<Expense> expenses;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView.builder(
      itemCount: expenses.length,
      itemBuilder: (ctx, index) => Dismissible(
        background: Container(
          color: Theme.of(context).colorScheme.error.withOpacity(0.75),
          margin: EdgeInsets.symmetric(
            horizontal: Theme.of(context).cardTheme.margin!.horizontal,
          ),
        ),
        key: ValueKey(expenses[index]),
        onDismissed: (direction) {
          ref.read(expenseProvider.notifier).removeExpense(expenses[index].id);
          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              duration: const Duration(seconds: 3),
              content: const Text(
                "Expense deleted",
              ),
              action: SnackBarAction(
                label: "Undo",
                onPressed: () {
                  ref.read(expenseProvider.notifier).addExpense(
                        expenses[index].title,
                        expenses[index].amount,
                        expenses[index].date,
                        expenses[index].category,
                      );
                },
              ),
            ),
          );
        },
        child: ExpenseItem(expenses[index]),
      ),
    );
  }
}
