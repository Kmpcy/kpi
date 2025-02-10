
import 'package:flutter/material.dart';

void main() => runApp(KPIApp());

class Department {
  String name;
  String password;
  List<Member> members;

  Department(this.name, this.password, this.members);
}

class Member {
  String name;
  Map<String, List<KpiItem>> monthlyKpis;

  Member(this.name) : monthlyKpis = {
    for (var month = 1; month <= 12; month++)
      'شهر ${month.toString().padLeft(2, '0')}': List.generate(
          12,
              (i) => KpiItem('عنصر التقييم ${i + 1}', 0, 0, 0, 0)
      )
  };
}

class KpiItem {
  String name;
  double week1;
  double week2;
  double week3;
  double week4;

  KpiItem(this.name, this.week1, this.week2, this.week3, this.week4);

  double get monthlyAverage => (week1 + week2 + week3 + week4) / 4;
}

class KPIApp extends StatefulWidget {
  @override
  _KPIAppState createState() => _KPIAppState();
}

class _KPIAppState extends State<KPIApp> {
  bool _isDarkMode = false;
  final List<Department> departments = [
    Department('IMP', 'imp123', []),
    Department('Data Base', 'db123', []),
    Department('Flutter', 'flutter123', []),
    Department('.Net', 'net123', []),
    Department('Ai', 'ai123', []),
    Department('Testing', 'test123', []),
    Department('OB', 'ob123', []),
  ];

  void _toggleTheme() {
    setState(() {
      _isDarkMode = !_isDarkMode;
    });
  }

  ThemeData _buildLightTheme() {
    return ThemeData(
      primarySwatch: Colors.blue,
      brightness: Brightness.light,
      cardTheme: CardTheme(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      ),
    );
  }

  ThemeData _buildDarkTheme() {
    return ThemeData(
      primarySwatch: Colors.blue,
      brightness: Brightness.dark,
      cardTheme: CardTheme(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'KPI System',
      theme: _isDarkMode ? _buildDarkTheme() : _buildLightTheme(),
      home: HomeScreen(
        departments: departments,
        isDarkMode: _isDarkMode,
        toggleTheme: _toggleTheme,
      ),
      routes: {
        '/dashboard': (ctx) => DashboardPasswordScreen(),
      },
    );
  }
}

class HomeScreen extends StatelessWidget {
  final List<Department> departments;
  final Function toggleTheme;
  final bool isDarkMode;

  HomeScreen({
    required this.departments,
    required this.toggleTheme,
    required this.isDarkMode,
  });

  void _navigateToDepartment(BuildContext context, Department department) async {
    final passwordController = TextEditingController();
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('${department.name} Department'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Enter department password:'),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Password',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );

    if (result == true && passwordController.text == department.password) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (ctx) => MembersScreen(department: department),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Departments'),
        actions: [
          IconButton(
            icon: Icon(isDarkMode ? Icons.light_mode : Icons.dark_mode),
            onPressed: () => toggleTheme(),
          ),
          IconButton(
            icon: const Icon(Icons.show_chart),
            onPressed: () => Navigator.pushNamed(context, '/dashboard'),
          ),
        ],
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.5,
        ),
        itemCount: departments.length,
        itemBuilder: (ctx, i) => Card(
          elevation: 4,
          child: InkWell(
            onTap: () => _navigateToDepartment(context, departments[i]),
            child: Center(
              child: Text(
                departments[i].name,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
class MembersScreen extends StatefulWidget {
  final Department department;

  const MembersScreen({required this.department});

  @override
  _MembersScreenState createState() => _MembersScreenState();
}

class _MembersScreenState extends State<MembersScreen> {
  void _addMember() async {
    final nameController = TextEditingController();
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('إضافة عضو جديد'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(labelText: 'اسم العضو'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                widget.department.members.add(Member(nameController.text));
              });
              Navigator.pop(context);
            },
            child: const Text('حفظ'),
          ),
        ],
      ),
    );
  }

  void _deleteMember(int index) {
    setState(() {
      widget.department.members.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.department.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _addMember,
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: widget.department.members.length,
        itemBuilder: (ctx, index) => Card(
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          child: ListTile(
            title: Text(widget.department.members[index].name),
            trailing: IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _deleteMember(index),
            ),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (ctx) => MonthsScreen(
                  member: widget.department.members[index],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class MonthsScreen extends StatelessWidget {
  final Member member;

  const MonthsScreen({required this.member});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('شهور السنة')),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemCount: 12,
        itemBuilder: (ctx, index) => Card(
          child: InkWell(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (ctx) => KpiTableScreen(
                  member: member,
                  month: 'شهر ${(index + 1).toString().padLeft(2, '0')}',
                ),
              ),
            ),
            child: Center(
              child: Text('شهر ${index + 1}'),
            ),
          ),
        ),
      ),
    );
  }
}

class KpiTableScreen extends StatefulWidget {
  final Member member;
  final String month;

  KpiTableScreen({required this.member, required this.month});

  @override
  _KpiTableScreenState createState() => _KpiTableScreenState();
}

class _KpiTableScreenState extends State<KpiTableScreen> {
  late List<TextEditingController> _controllers;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    _controllers = [];
    final kpis = widget.member.monthlyKpis[widget.month]!;
    for (var kpi in kpis) {
      _controllers.add(TextEditingController(text: kpi.name));
      _controllers.add(TextEditingController(text: kpi.week1.toString()));
      _controllers.add(TextEditingController(text: kpi.week2.toString()));
      _controllers.add(TextEditingController(text: kpi.week3.toString()));
      _controllers.add(TextEditingController(text: kpi.week4.toString()));
    }
  }

  void _saveData() {
    int controllerIndex = 0;
    final kpis = widget.member.monthlyKpis[widget.month]!;
    for (int i = 0; i < kpis.length; i++) {
      kpis[i].name = _controllers[controllerIndex++].text;
      kpis[i].week1 = double.tryParse(_controllers[controllerIndex++].text) ?? 0;
      kpis[i].week2 = double.tryParse(_controllers[controllerIndex++].text) ?? 0;
      kpis[i].week3 = double.tryParse(_controllers[controllerIndex++].text) ?? 0;
      kpis[i].week4 = double.tryParse(_controllers[controllerIndex++].text) ?? 0;
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.member.name} - ${widget.month}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveData,
          ),
        ],
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SingleChildScrollView(
          child: DataTable(
            columnSpacing: 20,
            columns: const [
              DataColumn(label: Text('عنصر التقييم')),
              DataColumn(label: Text('الأسبوع 1')),
              DataColumn(label: Text('الأسبوع 2')),
              DataColumn(label: Text('الأسبوع 3')),
              DataColumn(label: Text('الأسبوع 4')),
              DataColumn(label: Text('المتوسط')),
            ],
            rows: List.generate(12, (index) {
              final kpi = widget.member.monthlyKpis[widget.month]![index];
              int controllerIndex = index * 5;
              Color averageColor = kpi.monthlyAverage < 75 ? Colors.red : Theme.of(context).textTheme.bodyLarge!.color!;

              return DataRow(cells: [
                DataCell(TextFormField(
                  controller: _controllers[controllerIndex],
                  decoration: const InputDecoration(border: InputBorder.none),
                )),
                DataCell(TextFormField(
                  controller: _controllers[controllerIndex + 1],
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(border: InputBorder.none),
                )),
                DataCell(TextFormField(
                  controller: _controllers[controllerIndex + 2],
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(border: InputBorder.none),
                )),
                DataCell(TextFormField(
                  controller: _controllers[controllerIndex + 3],
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(border: InputBorder.none),
                )),
                DataCell(TextFormField(
                  controller: _controllers[controllerIndex + 4],
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(border: InputBorder.none),
                )),
                DataCell(
                  Text(
                    kpi.monthlyAverage.toStringAsFixed(2),
                    style: TextStyle(color: averageColor, fontWeight: FontWeight.bold),
                  ),
                ),
              ]);
            }),
          ),
        ),
      ),
    );
  }
}


class DashboardPasswordScreen extends StatefulWidget {
  @override
  _DashboardPasswordScreenState createState() => _DashboardPasswordScreenState();
}

class _DashboardPasswordScreenState extends State<DashboardPasswordScreen> {
  final _passwordController = TextEditingController();
  final _dashboardPassword = "admin123";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('لوحة التحكم')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'كلمة المرور',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (_passwordController.text == _dashboardPassword) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (ctx) => MonthSelectionScreen(),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('كلمة المرور غير صحيحة!'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: const Text('دخول'),
            ),
          ],
        ),
      ),
    );
  }
}

class MonthSelectionScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final app = context.findAncestorStateOfType<_KPIAppState>()!;

    return Scaffold(
      appBar: AppBar(
        title: const Text('اختر الشهر'),
        actions: [
          IconButton(
            icon: Icon(app._isDarkMode ? Icons.light_mode : Icons.dark_mode),
            onPressed: app._toggleTheme,
          ),
        ],
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemCount: 12,
        itemBuilder: (ctx, index) => Card(
          child: InkWell(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (ctx) => DepartmentListScreen(
                  selectedMonth: 'شهر ${(index + 1).toString().padLeft(2, '0')}',
                  departments: app.departments,
                ),
              ),
            ),
            child: Center(
              child: Text(
                'شهر ${index + 1}',
                style: const TextStyle(fontSize: 18),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class DepartmentListScreen extends StatelessWidget {
  final String selectedMonth;
  final List<Department> departments;

  const DepartmentListScreen({
    required this.selectedMonth,
    required this.departments,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('الأقسام - $selectedMonth')),
      body: ListView.builder(
        itemCount: departments.length,
        itemBuilder: (ctx, index) => Card(
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          child: ListTile(
            title: Text(departments[index].name),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (ctx) => DepartmentEvaluationScreen(
                  department: departments[index],
                  selectedMonth: selectedMonth,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class DepartmentEvaluationScreen extends StatelessWidget {
  final Department department;
  final String selectedMonth;

  const DepartmentEvaluationScreen({
    required this.department,
    required this.selectedMonth,
  });

  double _calculateMemberAverage(Member member) {
    final kpis = member.monthlyKpis[selectedMonth]!;
    if (kpis.isEmpty) return 0;
    final total = kpis.fold(0.0, (sum, kpi) => sum + kpi.monthlyAverage);
    return total / kpis.length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('${department.name} - $selectedMonth')),
      body: ListView.builder(
        itemCount: department.members.length,
        itemBuilder: (ctx, index) {
          final member = department.members[index];
          final average = _calculateMemberAverage(member);

          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: ExpansionTile(
              title: Text(member.name),
              subtitle: Text('المتوسط: ${average.toStringAsFixed(2)}'),
              children: member.monthlyKpis[selectedMonth]!.map((kpi) => ListTile(
                title: Text(kpi.name),
                trailing: Text(kpi.monthlyAverage.toStringAsFixed(2)),
              )).toList(),
            ),
          );
        }
      ),
    );
  }
}