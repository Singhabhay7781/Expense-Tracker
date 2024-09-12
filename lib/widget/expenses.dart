import 'package:expense_tracker/provider/expense_provider.dart';
import 'package:expense_tracker/widget/chart/chart.dart';
import 'package:expense_tracker/widget/expenses_list/expenses_list.dart';
import 'package:expense_tracker/widget/new_expense.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class Expenses extends ConsumerStatefulWidget {
  const Expenses({super.key});
  @override
  ConsumerState<Expenses> createState() {
    return _ExpensesState();
  }
}

class _ExpensesState extends ConsumerState<Expenses> {
  late Future<void>? _expenseFuture;
  @override
  void initState() {
    super.initState();
    _expenseFuture = ref.read(expenseProvider.notifier).loadExpense();
  }

  void _openAddExpenseOverLay() {
    showModalBottomSheet(
      isScrollControlled: true,
      useSafeArea: true,
      context: context,
      builder: (ctx) => const NewExpense(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final registeredExpenses = ref.watch(expenseProvider);

    Widget mainContent = const Center(
      child: Text("No Expenses found. Start adding Some!"),
    );

    if (registeredExpenses.isNotEmpty) {
      mainContent = ExpensesList(
        expenses: registeredExpenses,
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Flutter ExpenseTracker"),
        actions: [
          IconButton(
            onPressed: _openAddExpenseOverLay,
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: FutureBuilder(
        future: _expenseFuture,
        builder: (context, snapshot) =>
            snapshot.connectionState == ConnectionState.waiting
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : width < 600
                    ? Column(
                        children: [
                          Chart(expenses: registeredExpenses),
                          Expanded(child: mainContent),
                        ],
                      )
                    : Row(
                        children: [
                          Expanded(
                            child: Chart(expenses: registeredExpenses),
                          ),
                          Expanded(child: mainContent),
                        ],
                      ),
      ),
    );
  }
}
