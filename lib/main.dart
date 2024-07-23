import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.light);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (context, ThemeMode currentMode, child) {
        return MaterialApp(
          title: 'Mini Home Automation App',
          theme: ThemeData.light(),
          darkTheme: ThemeData.dark(),
          themeMode: currentMode,
          home: MyHomePage(themeNotifier: themeNotifier),
        );
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  final ValueNotifier<ThemeMode> themeNotifier;

  MyHomePage({required this.themeNotifier});

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;
  String _name = '';
  String _email = '';

  void _updateUserInfo(String name, String email) {
    setState(() {
      _name = name;
      _email = email;
    });
  }

  static List<Widget> _widgetOptions(
      ValueNotifier<ThemeMode> themeNotifier,
      String name,
      String email,
      Function(String, String) updateUserInfo,
      ) => [
    DashboardScreen(name: name, email: email),
    SettingsScreen(themeNotifier: themeNotifier, updateUserInfo: updateUserInfo),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mini Home Automation App'),
      ),
      body: Center(
        child: _widgetOptions(widget.themeNotifier, _name, _email, _updateUserInfo).elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}

class DashboardScreen extends StatefulWidget {
  final String name;
  final String email;

  DashboardScreen({required this.name, required this.email});

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _isLightOn = false;
  bool _isFanOn = false;
  double _waterConsumption = 0.0;
  double _gasConsumption = 0.0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final String response = await rootBundle.loadString('assets/data.json');
      final data = json.decode(response);
      setState(() {
        _waterConsumption = data['waterConsumption'];
        _gasConsumption = data['gasConsumption'];
      });
      print('Data loaded: $_waterConsumption, $_gasConsumption');
    } catch (e) {
      print('Error loading data: $e');
    }
  }

  void _toggleLight(bool value) {
    setState(() {
      _isLightOn = value;
    });
  }

  void _toggleFan(bool value) {
    setState(() {
      _isFanOn = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('User Name: ${widget.name}'),
          SizedBox(height: 10),
          Text('User Email: ${widget.email}'),
          SwitchListTile(
            title: Text('Light'),
            value: _isLightOn,
            onChanged: _toggleLight,
          ),
          SwitchListTile(
            title: Text('Fan'),
            value: _isFanOn,
            onChanged: _toggleFan,
          ),
          SizedBox(height: 20),
          Text('Water Consumption: $_waterConsumption L'),
          SizedBox(height: 10),
          Text('Gas Consumption: $_gasConsumption m³'),
        ],
      ),
    );
  }
}

class SettingsScreen extends StatefulWidget {
  final ValueNotifier<ThemeMode> themeNotifier;
  final Function(String, String) updateUserInfo;

  SettingsScreen({required this.themeNotifier, required this.updateUserInfo});

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = false;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  void _toggleNotifications(bool value) {
    setState(() {
      _notificationsEnabled = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SwitchListTile(
            title: Text('Dark Theme'),
            value: widget.themeNotifier.value == ThemeMode.dark,
            onChanged: (bool value) {
              widget.themeNotifier.value = value ? ThemeMode.dark : ThemeMode.light;
            },
          ),
          SwitchListTile(
            title: Text('Enable Notifications'),
            value: _notificationsEnabled,
            onChanged: _toggleNotifications,
          ),
          SizedBox(height: 20),
          Text('User Profile:'),
          SizedBox(height: 10),
          TextField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: 'Name',
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(height: 10),
          TextField(
            controller: _emailController,
            decoration: InputDecoration(
              labelText: 'Email',
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(height: 20),
          Center(
            child: ElevatedButton(
              onPressed: () {
                widget.updateUserInfo(_nameController.text, _emailController.text);
              },
              child: Text('Save'),
            ),
          ),
        ],
      ),
    );
  }
}
