import 'package:flutter/material.dart';

void main() {
  runApp(const FantaApp());
}

/* ================= STATE ================= */

class AppState extends ChangeNotifier {
  Map<String, String>? user;
  Map<String, dynamic> formations = {};

  void login(Map<String, String> u) {
    user = u;
    notifyListeners();
  }

  void logout() {
    user = null;
    notifyListeners();
  }

  void saveFormation(String username, Map<String, dynamic> data) {
    formations[username] = data;
    notifyListeners();
  }
}

final appState = AppState();

/* ================= PROVIDER ================= */

class AppScope extends InheritedNotifier<AppState> {
  const AppScope({
    super.key,
    required AppState notifier,
    required Widget child,
  }) : super(notifier: notifier, child: child);

  static AppState of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<AppScope>()!.notifier!;
  }
}

/* ================= APP ================= */

class FantaApp extends StatelessWidget {
  const FantaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScope(
      notifier: appState,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
          useMaterial3: true,
        ),
        home: const MainScreen(),
      ),
    );
  }
}

/* ================= USERS ================= */

final users = [
  {"username": "adelaide", "team": "Adelaide", "name": "Alberto"},
  {"username": "botafogo", "team": "Botafogo", "name": "Marco"},
  {"username": "verona", "team": "Verona", "name": "Luca"},
];

/* ================= TEAMS ================= */

class Team {
  final String name;
  final int points;
  final int won;
  final int drawn;
  final int lost;
  final int goalsFor;
  final int goalsAgainst;

  const Team({
    required this.name,
    required this.points,
    this.won = 0,
    this.drawn = 0,
    this.lost = 0,
    this.goalsFor = 0,
    this.goalsAgainst = 0,
  });

  int get goalDifference => goalsFor - goalsAgainst;
}

final teams = [
  Team(name: "Adelaide", points: 18, won: 5, drawn: 3, lost: 2, goalsFor: 15, goalsAgainst: 8),
  Team(name: "Botafogo", points: 22, won: 7, drawn: 1, lost: 2, goalsFor: 20, goalsAgainst: 10),
  Team(name: "Verona", points: 16, won: 4, drawn: 4, lost: 2, goalsFor: 12, goalsAgainst: 9),
  Team(name: "West Ham", points: 14, won: 4, drawn: 2, lost: 4, goalsFor: 11, goalsAgainst: 13),
  Team(name: "Pumas", points: 12, won: 3, drawn: 3, lost: 4, goalsFor: 10, goalsAgainst: 14),
  Team(name: "Palmeiras", points: 20, won: 6, drawn: 2, lost: 2, goalsFor: 18, goalsAgainst: 9),
  Team(name: "Sambenedettese", points: 10, won: 2, drawn: 4, lost: 4, goalsFor: 9, goalsAgainst: 15),
  Team(name: "Notts Country", points: 8, won: 2, drawn: 2, lost: 6, goalsFor: 7, goalsAgainst: 18),
];

/* ================= MATCH + CALENDAR ================= */

class Match {
  final String home;
  final String away;

  Match(this.home, this.away);
}

List<List<Match>> generateCalendar(List<Team> teams) {
  List<String> list = teams.map((e) => e.name).toList();

  if (list.length % 2 != 0) {
    list.add("Riposo");
  }

  int n = list.length;
  int half = n ~/ 2;

  List<List<Match>> schedule = [];
  List<String> fixed = List.from(list);

  // ANDATA + RITORNO BASE
  for (int r = 0; r < (n - 1) * 2; r++) {
    List<Match> round = [];

    for (int i = 0; i < half; i++) {
      String home = fixed[i];
      String away = fixed[n - 1 - i];

      if (home != "Riposo" && away != "Riposo") {
        round.add(r % 2 == 0
            ? Match(home, away)
            : Match(away, home));
      }
    }

    schedule.add(round);
    fixed.insert(1, fixed.removeLast());
  }

  // PORTA A 38 GIORNATE
  while (schedule.length < 38) {
    schedule.add(schedule[schedule.length % ((n - 1) * 2)]);
  }

  return schedule;
}

/* ================= MAIN ================= */

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int index = 0;

  List<Widget> get pages => const [
    HomePage(),
    TeamPage(),
    RankingPage(),
  ];

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          state.user == null
              ? "Fanta PRO"
              : "Ciao ${state.user?["name"] ?? "Mister"}",
        ),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              showDialog(
                context: context,
                builder: (_) {
                  final u = TextEditingController();
                  final p = TextEditingController();

                  return AlertDialog(
                    title: const Text("Login"),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextField(controller: u),
                        TextField(controller: p, obscureText: true),
                      ],
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          final found = users.firstWhere(
                                (e) => e["username"] == u.text,
                            orElse: () => {},
                          );

                          state.login({
                            "username": u.text,
                            "name": found["name"] ?? u.text,
                            "team": found["team"] ?? "Senza Team",
                          });

                          Navigator.pop(context);
                        },
                        child: const Text("Login"),
                      )
                    ],
                  );
                },
              );
            },
          ),
          if (state.user != null)
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () => state.logout(),
            )
        ],
      ),
      body: pages[index],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: index,
        onTap: (i) => setState(() => index = i),

        selectedItemColor: Colors.orange,   // 👈 colore icona attiva
        unselectedItemColor: Colors.grey,        // 👈 colore icone non attive
        backgroundColor: Colors.black,           // 👈 fondo barra
        type: BottomNavigationBarType.fixed,

        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.groups),
            label: "Rosa",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.leaderboard),
            label: "Classifica",
          ),
        ],
      ),
    );
  }
}

/* ================= HOME (REDESIGNED MODERN UI) ================= */

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);

    final isLogged = state.user != null;

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              /* ===== HEADER CARD ===== */
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white24),
                ),
                child: Row(
                  children: [
                    const CircleAvatar(
                      radius: 28,
                      backgroundColor: Colors.black,
                      child: Icon(Icons.sports_soccer, color: Colors.white),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        isLogged
                            ? "Bentornato, ${state.user?["name"]}"
                            : "Benvenuto Mister",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              /* ===== QUICK ACTIONS ===== */
              const Text(
                "Azioni rapide",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 12),

              Row(
                children: [
                  _ActionCard(
                    icon: Icons.calendar_month,
                    label: "Calendario",
                    color: Colors.orange,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const CalendarPage(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 12),
                  _ActionCard(
                    icon: Icons.sports,
                    label: "Formazione",
                    color: Colors.blue,
                    onTap: isLogged
                        ? () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => FormationPage(
                            username: state.user!["username"]!,
                            team: state.user!["team"]!,
                          ),
                        ),
                      );
                    }
                        : null,
                  ),
                ],
              ),

              const SizedBox(height: 20),

              /* ===== INFO CARD ===== */
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Fanta PRO",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      "Gestisci la tua squadra, schiera la formazione e domina la classifica.",
                      style: TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/* ================= ACTION CARD WIDGET ================= */

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onTap;

  const _ActionCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.white24),
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 32),
              const SizedBox(height: 10),
              Text(
                label,
                style: const TextStyle(color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/* ================= CALENDAR PAGE ================= */

class CalendarPage extends StatelessWidget {
  const CalendarPage({super.key});

  @override
  Widget build(BuildContext context) {
    final calendar = generateCalendar(teams);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Calendario"),
        backgroundColor: Colors.black,
      ),
      body: ListView.builder(
        itemCount: calendar.length,
        itemBuilder: (context, i) {
          return ExpansionTile(
            title: Text("Giornata ${i + 1}"),
            children: calendar[i]
                .map((m) => ListTile(
              title: Text("${m.home} vs ${m.away}"),
            ))
                .toList(),
          );
        },
      ),
    );
  }
}

/* ================= FORMATION PAGE ================= */

class FormationPage extends StatefulWidget {
  final String username;
  final String team;

  const FormationPage({
    super.key,
    required this.username,
    required this.team,
  });

  @override
  State<FormationPage> createState() => _FormationPageState();
}

class _FormationPageState extends State<FormationPage> {
  String? selectedModule;

  Map<String, List<TextEditingController>> controllers = {};

  final modules = {
    "4-4-2": {"POR": 1, "DIF": 4, "CEN": 4, "ATT": 2},
    "4-2-3-1": {"POR": 1, "DIF": 4, "CEN": 3, "ATT": 3},
    "4-3-3": {"POR": 1, "DIF": 4, "CEN": 3, "ATT": 3},
    "3-5-2": {"POR": 1, "DIF": 3, "CEN": 5, "ATT": 2},
    "3-4-3": {"POR": 1, "DIF": 3, "CEN": 4, "ATT": 3},
  };

  void initControllers() {
    controllers.clear();

    final structure = modules[selectedModule];
    if (structure == null) return;

    structure.forEach((role, count) {
      controllers[role] =
          List.generate(count, (_) => TextEditingController());
    });

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.team),
        backgroundColor: Colors.green,
      ),
      body: Column(
        children: [
          DropdownButton<String>(
            value: selectedModule,
            hint: const Text("Seleziona modulo"),
            items: modules.keys
                .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                .toList(),
            onChanged: (value) {
              selectedModule = value;
              initControllers();
            },
          ),
        ],
      ),
    );
  }
}

/* ================= OTHER PAGES ================= */

class TeamPage extends StatelessWidget {
  const TeamPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Rosa Squadre"),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: teams.length,
          itemBuilder: (context, i) {
            final team = teams[i];

            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => TeamDetailPage(team: team),
                  ),
                );
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: Colors.white24),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.greenAccent,
                      child: Text(
                        team.name.substring(0, 1),
                        style: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        team.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios,
                        color: Colors.white54, size: 16),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
class TeamDetailPage extends StatelessWidget {
  final Team team;

  const TeamDetailPage({super.key, required this.team});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(team.name),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)],
          ),
        ),
        child: Column(
          children: [
            const SizedBox(height: 20),

            /* HEADER SQUADRA */
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.08),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 28,
                    backgroundColor: Colors.green,
                    child: Icon(Icons.groups, color: Colors.black),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      team.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            const Text(
              "Rosa giocatori (in arrivo)",
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),

            const SizedBox(height: 20),

            /* PLACEHOLDER ROSA */
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: 6,
                itemBuilder: (context, i) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.06),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.person, color: Colors.white54),
                        SizedBox(width: 10),
                        Text(
                          "Giocatore (placeholder)",
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class RankingPage extends StatelessWidget {
  const RankingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final sorted = [...teams]
      ..sort((a, b) => b.points.compareTo(a.points));

    return Scaffold(
      appBar: AppBar(
        title: const Text("Classifica Serie Fanta"),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: sorted.length,
          itemBuilder: (context, i) {
            final t = sorted[i];

            /* ===== PODIO COLOR ===== */
            Color color;
            IconData icon;

            if (i == 0) {
              color = Colors.amber;
              icon = Icons.emoji_events;
            } else if (i == 1) {
              color = Colors.grey;
              icon = Icons.emoji_events_outlined;
            } else if (i == 2) {
              color = Colors.brown;
              icon = Icons.emoji_events_outlined;
            } else {
              color = Colors.white24;
              icon = Icons.sports_soccer;
            }

            /* ===== SIMULAZIONE TREND (↑ ↓) ===== */
            final trend = (i % 2 == 0) ? Icons.arrow_upward : Icons.arrow_downward;
            final trendColor = (i % 2 == 0) ? Colors.green : Colors.red;

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.08),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: color.withOpacity(0.4)),
              ),
              child: Column(
                children: [

                  /* ===== RIGA PRINCIPALE ===== */
                  Row(
                    children: [

                      CircleAvatar(
                        backgroundColor: color,
                        child: Text(
                          "${i + 1}",
                          style: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      const SizedBox(width: 12),

                      Icon(icon, color: color),

                      const SizedBox(width: 10),

                      Expanded(
                        child: Text(
                          t.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      Icon(trend, color: trendColor, size: 18),

                      const SizedBox(width: 10),

                      Text(
                        "${t.points} pt",
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  /* ===== STATISTICHE ===== */
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _stat("V", t.won),
                      _stat("N", t.drawn),
                      _stat("P", t.lost),
                      _stat("GF", t.goalsFor),
                      _stat("GS", t.goalsAgainst),
                      _stat("DR", t.goalDifference),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _stat(String label, int value) {
    return Column(
      children: [
        Text(
          "$value",
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white54,
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}