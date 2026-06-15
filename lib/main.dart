import 'package:flutter/material.dart';

void main() {
  runApp(const FantaApp());
}

class FantaApp extends StatelessWidget {
  const FantaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Fanta Manager',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: const MainScreen(),
    );
  }
}

//
// ================= MAIN =================
//
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int index = 0;
  String? userLogged;

  final pages = const [
    HomePage(),
    TeamPage(),
    RankingPage(),
  ];

  void _showLoginDialog() {
    final userController = TextEditingController();
    final passController = TextEditingController();
    String error = '';

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: Text(userLogged == null ? 'Login' : 'Account'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (userLogged == null) ...[
                    TextField(
                      controller: userController,
                      decoration:
                      const InputDecoration(labelText: 'Username'),
                    ),
                    TextField(
                      controller: passController,
                      obscureText: true,
                      decoration:
                      const InputDecoration(labelText: 'Password'),
                    ),
                    if (error.isNotEmpty)
                      Text(
                        error,
                        style: const TextStyle(color: Colors.red),
                      ),
                  ] else
                    Text('Loggato come: $userLogged'),
                ],
              ),
              actions: [
                if (userLogged == null)
                  TextButton(
                    onPressed: () {
                      if (userController.text == 'admin' &&
                          passController.text == '1234') {
                        setState(() {
                          userLogged = userController.text;
                        });
                        Navigator.pop(context);
                      } else {
                        setStateDialog(() {
                          error = 'Credenziali non valide';
                        });
                      }
                    },
                    child: const Text('Login'),
                  )
                else
                  TextButton(
                    onPressed: () {
                      setState(() {
                        userLogged = null;
                      });
                      Navigator.pop(context);
                    },
                    child: const Text('Logout'),
                  ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fanta Manager'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: _showLoginDialog,
          )
        ],
      ),
      body: pages[index],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: index,
        onTap: (i) => setState(() => index = i),
        selectedItemColor: Colors.green,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.groups), label: 'Rosa'),
          BottomNavigationBarItem(icon: Icon(Icons.leaderboard), label: 'Classifica'),
        ],
      ),
    );
  }
}

//
// ================= HOME MODERNA =================
//
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Ciao, Mister 👋',
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 5),
              const Text(
                'Ecco la situazione della tua squadra',
                style: TextStyle(color: Colors.grey),
              ),

              const SizedBox(height: 20),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Colors.green, Colors.lightGreen],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.white,
                      child: Icon(Icons.sports_soccer,
                          color: Colors.green, size: 30),
                    ),
                    SizedBox(width: 15),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'FC Alberto',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '3° posto in classifica',
                          style: TextStyle(color: Colors.white70),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              Row(
                children: [
                  _statCard('Punti', '58', Icons.star, Colors.orange),
                  const SizedBox(width: 10),
                  _statCard('Media', '6.8', Icons.trending_up, Colors.blue),
                ],
              ),

              const SizedBox(height: 20),

              _infoCard('Prossima giornata',
                  'FC Alberto vs Real Fantasia', Icons.calendar_month),

              const SizedBox(height: 10),

              _infoCard('Ultima partita',
                  'FC Alberto 2 - 1 Napoli Stars', Icons.sports_score),

              const SizedBox(height: 20),

              const Text(
                'Azioni rapide',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 10),

              Row(
                children: [
                  _action(Icons.groups, 'Rosa', Colors.blue),
                  const SizedBox(width: 10),
                  _action(Icons.shopping_cart, 'Mercato', Colors.orange),
                  const SizedBox(width: 10),
                  _action(Icons.leaderboard, 'Classifica', Colors.purple),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statCard(String t, String v, IconData i, Color c) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          children: [
            Icon(i, color: c),
            const SizedBox(height: 10),
            Text(v,
                style:
                const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            Text(t, style: const TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _infoCard(String t, String s, IconData i) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          Icon(i, color: Colors.green),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(t, style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(s, style: const TextStyle(color: Colors.grey)),
            ],
          )
        ],
      ),
    );
  }

  Widget _action(IconData i, String l, Color c) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          children: [
            Icon(i, color: c),
            const SizedBox(height: 5),
            Text(l),
          ],
        ),
      ),
    );
  }
}

//
// ================= ROSA =================
//
class TeamPage extends StatelessWidget {
  const TeamPage({super.key});

  @override
  Widget build(BuildContext context) {
    final players = ['Ronaldo', 'Leao', 'Vlahovic', 'Barella', 'Theo'];

    return ListView.builder(
      itemCount: players.length,
      itemBuilder: (context, i) {
        return Card(
          child: ListTile(
            leading: const Icon(Icons.sports_soccer),
            title: Text(players[i]),
          ),
        );
      },
    );
  }
}

//
// ================= CLASSIFICA =================
//
class RankingPage extends StatelessWidget {
  const RankingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final teams = [
      ('Dream Team', 65),
      ('Galacticos', 61),
      ('FC Alberto', 58),
      ('FC Roma', 52),
    ];

    return ListView.builder(
      itemCount: teams.length,
      itemBuilder: (context, i) {
        final t = teams[i];
        return ListTile(
          leading: CircleAvatar(child: Text('${i + 1}')),
          title: Text(t.$1),
          trailing: Text('${t.$2} pt'),
        );
      },
    );
  }
}