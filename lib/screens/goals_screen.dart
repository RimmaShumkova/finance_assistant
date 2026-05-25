import 'package:flutter/material.dart';

import '../models/expense_category.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';

class GoalsScreen extends StatefulWidget {
  const GoalsScreen({super.key});

  @override
  State<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends State<GoalsScreen> {
  final ApiService _apiService = ApiService();
  List<FinancialGoal> _goals = [];
  bool _isLoading = true;

  int get _activeCount => _goals.where((goal) => goal.status == 'active').length;
  int get _completedCount =>
      _goals.where((goal) => goal.status == 'completed').length;

  double get _monthlyRecommendation {
    for (final goal in _goals) {
      if (goal.status == 'active') return goal.recommendedMonthlyAmount;
    }
    return 0;
  }

  @override
  void initState() {
    super.initState();
    _loadGoals();
  }

  Future<void> _loadGoals() async {
    setState(() => _isLoading = true);
    try {
      final goals = await _apiService.getGoals();
      if (!mounted) return;
      setState(() {
        _goals = goals;
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        AppTheme.errorSnackBar(error.toString()),
      );
    }
  }

  Future<void> _showCreateDialog() async {
    final draft = await showDialog<_GoalDraft>(
      context: context,
      builder: (context) => const _GoalDialog(),
    );

    if (draft == null) return;
    try {
      await _apiService.createGoal(
        title: draft.title,
        targetAmount: draft.targetAmount,
        currentAmount: draft.currentAmount,
      );
      await _loadGoals();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        AppTheme.errorSnackBar(error.toString()),
      );
    }
  }

  Future<void> _showContributionDialog(FinancialGoal goal) async {
    final amount = await showDialog<double>(
      context: context,
      builder: (context) => _ContributionDialog(goal: goal),
    );

    if (amount == null) return;
    try {
      await _apiService.addGoalContribution(goalId: goal.id, amount: amount);
      await _loadGoals();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        AppTheme.errorSnackBar(error.toString()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.black,
      appBar: AppBar(
        title: const Text('Финансовые цели'),
        actions: [
          IconButton(
            tooltip: 'Обновить',
            icon: const Icon(Icons.refresh),
            onPressed: _loadGoals,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateDialog,
        backgroundColor: AppTheme.yellow,
        foregroundColor: AppTheme.black,
        child: const Icon(Icons.add),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.yellow))
          : RefreshIndicator(
              color: AppTheme.yellow,
              onRefresh: _loadGoals,
              child: _goals.isEmpty ? _buildEmptyState() : _buildGoalsList(),
            ),
    );
  }

  Widget _buildEmptyState() {
    return ListView(
      children: const [
        SizedBox(height: 180),
        Icon(Icons.flag_outlined, color: AppTheme.yellow, size: 54),
        SizedBox(height: 16),
        Center(
          child: Text('Целей пока нет', style: AppTheme.titleSmall),
        ),
        SizedBox(height: 8),
        Center(
          child: Text(
            'Добавьте цель накопления кнопкой ниже',
            style: AppTheme.bodyMedium,
          ),
        ),
      ],
    );
  }

  Widget _buildGoalsList() {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 900),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
          children: [
            _buildSummaryPanel(),
            const SizedBox(height: 14),
            ..._goals.map(_buildGoalCard),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryPanel() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.blackCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.yellow.withOpacity(0.24)),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildSummaryItem(
              label: 'Активные',
              value: _activeCount.toString(),
              color: AppTheme.yellow,
            ),
          ),
          Expanded(
            child: _buildSummaryItem(
              label: 'Завершены',
              value: _completedCount.toString(),
              color: AppTheme.green,
            ),
          ),
          Expanded(
            child: _buildSummaryItem(
              label: 'В месяц',
              value: _money(_monthlyRecommendation),
              color: AppTheme.greyLight,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem({
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTheme.bodySmall),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }

  Widget _buildGoalCard(FinancialGoal goal) {
    final completed = goal.status == 'completed';
    final remaining = (goal.targetAmount - goal.currentAmount).clamp(0, double.infinity);
    final progress = (goal.progressPercent / 100).clamp(0.0, 1.0);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.blackCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: completed
              ? AppTheme.green.withOpacity(0.28)
              : AppTheme.yellow.withOpacity(0.24),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: completed ? AppTheme.greenLight : AppTheme.yellowLight,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  completed ? Icons.check_rounded : Icons.flag_rounded,
                  color: completed ? AppTheme.green : AppTheme.yellow,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  goal.title,
                  style: AppTheme.titleSmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              _buildStatusBadge(completed),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: AppTheme.grey.withOpacity(0.25),
              color: completed ? AppTheme.green : AppTheme.yellow,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildAmountBlock(
                  label: 'Накоплено',
                  value: _money(goal.currentAmount),
                  color: AppTheme.white,
                ),
              ),
              Expanded(
                child: _buildAmountBlock(
                  label: 'Цель',
                  value: _money(goal.targetAmount),
                  color: AppTheme.greyLight,
                ),
              ),
              Expanded(
                child: _buildAmountBlock(
                  label: completed ? 'Статус' : 'Осталось',
                  value: completed ? 'Готово' : _money(remaining.toDouble()),
                  color: completed ? AppTheme.green : AppTheme.yellow,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (!completed)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: AppTheme.blackSecondary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.savings_outlined, color: AppTheme.yellow, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Рекомендация: ${_money(goal.recommendedMonthlyAmount)} в месяц',
                      style: AppTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            )
          else
            Text('Цель завершена, пополнение больше не требуется.',
                style: AppTheme.bodySmall),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: completed ? null : () => _showContributionDialog(goal),
              style: AppTheme.yellowButtonSmall,
              icon: const Icon(Icons.add_card_rounded, size: 18),
              label: const Text('Пополнить'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(bool completed) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: completed ? AppTheme.greenLight : AppTheme.yellowLight,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        completed ? 'Готово' : 'Активна',
        style: TextStyle(
          color: completed ? AppTheme.green : AppTheme.yellow,
          fontSize: 12,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Widget _buildAmountBlock({
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTheme.bodySmall),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  String _money(double value) => '${value.toStringAsFixed(0)} ₽';
}

class _GoalDraft {
  const _GoalDraft({
    required this.title,
    required this.targetAmount,
    required this.currentAmount,
  });

  final String title;
  final double targetAmount;
  final double currentAmount;
}

class _GoalDialog extends StatefulWidget {
  const _GoalDialog();

  @override
  State<_GoalDialog> createState() => _GoalDialogState();
}

class _GoalDialogState extends State<_GoalDialog> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _targetController = TextEditingController();
  final TextEditingController _currentController = TextEditingController(text: '0');
  String? _error;

  @override
  void dispose() {
    _titleController.dispose();
    _targetController.dispose();
    _currentController.dispose();
    super.dispose();
  }

  void _submit() {
    final title = _titleController.text.trim();
    final target = _tryReadInput(_targetController.text);
    final current = _tryReadInput(_currentController.text) ?? 0;

    if (title.isEmpty) {
      setState(() => _error = 'Введите название цели.');
      return;
    }
    if (target == null || target <= 0) {
      setState(() => _error = 'Введите сумму цели больше нуля.');
      return;
    }
    if (current < 0) {
      setState(() => _error = 'Текущая сумма не может быть отрицательной.');
      return;
    }

    Navigator.pop(
      context,
      _GoalDraft(title: title, targetAmount: target, currentAmount: current),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 430),
        child: Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: AppTheme.blackCard,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppTheme.yellow.withOpacity(0.22)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: AppTheme.iconCircle,
                    child: const Icon(Icons.flag_rounded, color: AppTheme.yellow),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text('Новая цель', style: AppTheme.titleMedium),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _titleController,
                autofocus: true,
                style: const TextStyle(color: AppTheme.white),
                decoration: AppTheme.inputDecoration(
                  hintText: 'Например, отпуск',
                  prefixIcon: const Icon(Icons.drive_file_rename_outline),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _targetController,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: AppTheme.white),
                decoration: AppTheme.inputDecoration(
                  hintText: 'Нужно накопить',
                  suffixText: '₽',
                  prefixIcon: const Icon(Icons.track_changes_rounded),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _currentController,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: AppTheme.white),
                decoration: AppTheme.inputDecoration(
                  hintText: 'Уже накоплено',
                  suffixText: '₽',
                  prefixIcon: const Icon(Icons.savings_outlined),
                ),
              ),
              if (_error != null) ...[
                const SizedBox(height: 12),
                Text(_error!, style: const TextStyle(color: AppTheme.red)),
              ],
              const SizedBox(height: 22),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: AppTheme.outlinedButton,
                      child: const Text('Отмена'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _submit,
                      style: AppTheme.yellowButtonSmall,
                      child: const Text('Создать'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ContributionDialog extends StatefulWidget {
  const _ContributionDialog({required this.goal});

  final FinancialGoal goal;

  @override
  State<_ContributionDialog> createState() => _ContributionDialogState();
}

class _ContributionDialogState extends State<_ContributionDialog> {
  final TextEditingController _controller = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final amount = _tryReadInput(_controller.text);
    if (amount == null || amount <= 0) {
      setState(() => _error = 'Введите сумму больше нуля.');
      return;
    }
    Navigator.pop(context, amount);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 390),
        child: Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: AppTheme.blackCard,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppTheme.yellow.withOpacity(0.22)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Пополнить цель', style: AppTheme.titleMedium),
              const SizedBox(height: 6),
              Text(widget.goal.title, style: AppTheme.bodyMedium),
              const SizedBox(height: 18),
              TextField(
                controller: _controller,
                autofocus: true,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: AppTheme.white),
                decoration: AppTheme.inputDecoration(
                  hintText: 'Сумма пополнения',
                  suffixText: '₽',
                  prefixIcon: const Icon(Icons.add_card_rounded),
                ),
              ),
              if (_error != null) ...[
                const SizedBox(height: 12),
                Text(_error!, style: const TextStyle(color: AppTheme.red)),
              ],
              const SizedBox(height: 22),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: AppTheme.outlinedButton,
                      child: const Text('Отмена'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _submit,
                      style: AppTheme.yellowButtonSmall,
                      child: const Text('Пополнить'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

double? _tryReadInput(String value) {
  return double.tryParse(value.trim().replaceAll(',', '.'));
}
