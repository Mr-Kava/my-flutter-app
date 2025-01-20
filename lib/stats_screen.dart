import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'database_helper.dart';

class StatsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Статистика'),
      ),
      body: FutureBuilder<Map<String, int>>(
        future: _loadStats(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Ошибка: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return Center(child: Text('Нет данных'));
          } else {
            final stats = snapshot.data!;
            return ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                Text(
                  'Статистика задач',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                SizedBox(height: 16),
                // Круговая диаграмма для задач
                _buildPieChart(
                    stats['completedTasks'] ?? 0, stats['activeTasks'] ?? 0),
                SizedBox(height: 32),
                // Карточки со статистикой
                _buildStatsGrid(stats),
              ],
            );
          }
        },
      ),
    );
  }

  // Метод для загрузки статистики
  Future<Map<String, int>> _loadStats() async {
    final dbHelper = DatabaseHelper();

    final notes = await dbHelper.getNotes();
    final tasks = await dbHelper.getTasks();

    final totalNotes = notes.length;
    final totalTasks = tasks.length;
    final completedTasks = tasks.where((task) => task.isCompleted).length;
    final activeTasks = totalTasks - completedTasks;

    return {
      'totalNotes': totalNotes,
      'totalTasks': totalTasks,
      'completedTasks': completedTasks,
      'activeTasks': activeTasks,
    };
  }

  // Виджет для отображения карточек со статистикой в виде сетки
  Widget _buildStatsGrid(Map<String, int> stats) {
    return GridView.count(
      shrinkWrap: true, // Занимает только необходимое пространство
      physics: NeverScrollableScrollPhysics(), // Отключаем внутренний скролл
      crossAxisCount: 2, // Два столбца
      childAspectRatio: 0.9, // Соотношение сторон карточек
      crossAxisSpacing: 16, // Расстояние между столбцами
      mainAxisSpacing: 16, // Расстояние между строками
      padding: EdgeInsets.zero, // Убираем лишние отступы
      children: [
        _buildStatCard(
            'Всего заметок', stats['totalNotes'] ?? 0, Icons.note, Colors.blue),
        _buildStatCard(
            'Всего задач', stats['totalTasks'] ?? 0, Icons.task, Colors.purple),
        _buildStatCard('Завершенные задачи', stats['completedTasks'] ?? 0,
            Icons.check_circle, Colors.green),
        _buildStatCard('Активные задачи', stats['activeTasks'] ?? 0,
            Icons.access_time, Colors.orange),
      ],
    );
  }

  // Виджет для отображения карточки со статистикой
  Widget _buildStatCard(String title, int value, IconData icon, Color color) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 40,
              color: color,
            ),
            SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8),
            Text(
              value.toString(),
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Виджет для круговой диаграммы
  Widget _buildPieChart(int completedTasks, int activeTasks) {
    return Column(
      children: [
        SizedBox(
          height: 200,
          child: SfCircularChart(
            series: <CircularSeries>[
              PieSeries<ChartData, String>(
                dataSource: [
                  ChartData(
                      'Завершенные', completedTasks.toDouble(), Colors.green),
                  ChartData('Активные', activeTasks.toDouble(), Colors.orange),
                ],
                xValueMapper: (ChartData data, _) => data.category,
                yValueMapper: (ChartData data, _) => data.value,
                pointColorMapper: (ChartData data, _) => data.color,
                dataLabelSettings: DataLabelSettings(
                  isVisible: true,
                  textStyle:
                      TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  builder: (dynamic data, dynamic point, dynamic series,
                      int pointIndex, int seriesIndex) {
                    // Форматируем значение как целое число
                    final value = data.value.toInt();
                    return Text('$value');
                  },
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 16),
        _buildLegend(),
      ],
    );
  }

  // Виджет для легенды диаграммы
  Widget _buildLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildLegendItem(Colors.green, 'Завершенные задачи'),
        SizedBox(width: 16),
        _buildLegendItem(Colors.orange, 'Активные задачи'),
      ],
    );
  }

  // Виджет для элемента легенды
  Widget _buildLegendItem(Color color, String text) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        SizedBox(width: 8),
        Text(
          text,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

// Модель данных для диаграммы
class ChartData {
  final String category;
  final double value;
  final Color color;

  ChartData(this.category, this.value, this.color);
}
