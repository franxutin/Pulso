import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: const String.fromEnvironment('SUPABASE_URL'),
    publishableKey: const String.fromEnvironment('SUPABASE_ANON_KEY'),
  );
  runApp(const PulsoApp());
}

class PulsoApp extends StatelessWidget {
  const PulsoApp({super.key});

  @override
  Widget build(BuildContext context) {
    const navy = Color(0xFF101629);
    const electric = Color(0xFF6D75FF);
    return MaterialApp(
      title: 'PULSO',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: navy,
        colorScheme: ColorScheme.fromSeed(
          seedColor: electric,
          brightness: Brightness.dark,
          surface: const Color(0xFF1A2340),
        ),
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      home: const PulsoHome(),
    );
  }
}

class Mission {
  const Mission({
    required this.title,
    required this.description,
    required this.category,
    required this.xp,
    required this.minutes,
  });

  final String title;
  final String description;
  final String category;
  final int xp;
  final int minutes;
}

class PulsoHome extends StatefulWidget {
  const PulsoHome({super.key});

  @override
  State<PulsoHome> createState() => _PulsoHomeState();
}

class _PulsoHomeState extends State<PulsoHome> {
  int _tab = 0;
  int _xp = 0;
  String _nickname = 'Jugador PULSO';
  String _country = 'España';
  final Set<String> _completed = {};

  final List<Mission> _missions = const [
    Mission(
      title: 'Un gesto positivo',
      description: 'Haz algo amable por alguien hoy. Puede ser una ayuda pequeña.',
      category: 'Acciones positivas',
      xp: 50,
      minutes: 3,
    ),
    Mission(
      title: 'Observa a tu alrededor',
      description: 'Encuentra tres detalles de tu entorno que normalmente pasarías por alto.',
      category: 'Observación',
      xp: 40,
      minutes: 2,
    ),
    Mission(
      title: 'Desafío de memoria',
      description: 'Mira cinco objetos durante 20 segundos, aparta la vista e intenta recordarlos.',
      category: 'Concentración',
      xp: 50,
      minutes: 3,
    ),
    Mission(
      title: 'Una idea para mejorar',
      description: 'Piensa en una mejora sencilla para tu barrio o comunidad.',
      category: 'Creatividad',
      xp: 60,
      minutes: 4,
    ),
  ];

  int get _level {
    if (_xp >= 3200) return 10;
    if (_xp >= 2500) return 9;
    if (_xp >= 1900) return 8;
    if (_xp >= 1400) return 7;
    if (_xp >= 1000) return 6;
    if (_xp >= 700) return 5;
    if (_xp >= 450) return 4;
    if (_xp >= 250) return 3;
    if (_xp >= 100) return 2;
    return 1;
  }

  int get _nextLevelXp {
    const thresholds = [100, 250, 450, 700, 1000, 1400, 1900, 2500, 3200];
    if (_level >= 10) return 3200;
    return thresholds[_level - 1];
  }

  int get _currentLevelBase {
    const thresholds = [0, 100, 250, 450, 700, 1000, 1400, 1900, 2500, 3200];
    return thresholds[_level - 1];
  }

  void _completeMission(Mission mission) {
    if (_completed.contains(mission.title)) return;
    setState(() {
      _completed.add(mission.title);
      _xp += mission.xp;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('¡Reto completado! +${mission.xp} XP')),
    );
  }

  void _editProfile() {
    final nameController = TextEditingController(text: _nickname);
    String selectedCountry = _country;
    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Tu perfil PULSO'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                maxLength: 20,
                decoration: const InputDecoration(labelText: 'Apodo'),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: selectedCountry,
                decoration: const InputDecoration(labelText: 'País'),
                items: const ['España', 'Francia', 'Alemania', 'Italia', 'Portugal', 'México', 'Argentina', 'Colombia']
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (value) {
                  if (value != null) setDialogState(() => selectedCountry = value);
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () {
                setState(() {
                  _nickname = nameController.text.trim().isEmpty
                      ? 'Jugador PULSO'
                      : nameController.text.trim();
                  _country = selectedCountry;
                });
                Navigator.pop(dialogContext);
              },
              child: const Text('Guardar'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      _homePage(),
      _missionsPage(),
      _worldPage(),
      _rankingPage(),
      _profilePage(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('PULSO', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 2)),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Chip(
                avatar: const Icon(Icons.bolt, size: 17, color: Color(0xFFFFD166)),
                label: Text('$_xp XP'),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(child: pages[_tab]),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: (index) => setState(() => _tab = index),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Inicio'),
          NavigationDestination(icon: Icon(Icons.flag_outlined), selectedIcon: Icon(Icons.flag), label: 'Retos'),
          NavigationDestination(icon: Icon(Icons.public_outlined), selectedIcon: Icon(Icons.public), label: 'World'),
          NavigationDestination(icon: Icon(Icons.emoji_events_outlined), selectedIcon: Icon(Icons.emoji_events), label: 'Ranking'),
          NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Perfil'),
        ],
      ),
    );
  }

  Widget _homePage() {
    final remaining = _missions.where((m) => !_completed.contains(m.title)).length;
    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        Text('¡Hola, $_nickname!', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        Text('Hoy tienes una misión que cumplir.', style: TextStyle(color: Colors.white.withOpacity(.7))),
        const SizedBox(height: 20),
        _levelCard(),
        const SizedBox(height: 18),
        _sectionTitle('MISIÓN DESTACADA', 'Ver retos', () => setState(() => _tab = 1)),
        _missionCard(_missions.first),
        const SizedBox(height: 18),
        Row(
          children: [
            Expanded(child: _statCard('Retos pendientes', '$remaining', Icons.track_changes)),
            const SizedBox(width: 12),
            Expanded(child: _statCard('País', _country, Icons.flag)),
          ],
        ),
        const SizedBox(height: 18),
        _sectionTitle('EL MUNDO TE ESPERA', 'Entrar', () => setState(() => _tab = 2)),
        _worldPreview(),
      ],
    );
  }

  Widget _levelCard() {
    final progress = _level >= 10
        ? 1.0
        : ((_xp - _currentLevelBase) / (_nextLevelXp - _currentLevelBase)).clamp(0.0, 1.0);
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: const LinearGradient(colors: [Color(0xFF414CCB), Color(0xFF8B55D8)]),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('NIVEL $_level', style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2)),
              const Icon(Icons.auto_awesome, size: 28),
            ],
          ),
          const SizedBox(height: 12),
          Text('$_xp XP', style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w900)),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: LinearProgressIndicator(value: progress, minHeight: 9, backgroundColor: Colors.white24, color: Colors.white),
          ),
          const SizedBox(height: 8),
          Text(_level >= 10 ? '¡Nivel máximo de esta demo!' : '${_nextLevelXp - _xp} XP para el siguiente nivel'),
        ],
      ),
    );
  }

  Widget _missionsPage() {
    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        Text('Tus retos', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        Text('Misiones cortas para mantener tu PULSO activo.', style: TextStyle(color: Colors.white.withOpacity(.7))),
        const SizedBox(height: 18),
        ..._missions.map(_missionCard),
      ],
    );
  }

  Widget _missionCard(Mission mission) {
    final done = _completed.contains(mission.title);
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.bolt, color: Color(0xFFFFD166)),
                const SizedBox(width: 6),
                Expanded(child: Text(mission.category.toUpperCase(), style: const TextStyle(fontSize: 11, letterSpacing: 1, color: Colors.white70))),
                Text('${mission.xp} XP', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFFFD166))),
              ],
            ),
            const SizedBox(height: 10),
            Text(mission.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Text(mission.description, style: TextStyle(color: Colors.white.withOpacity(.75))),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.schedule, size: 16, color: Colors.white.withOpacity(.6)),
                const SizedBox(width: 5),
                Text('${mission.minutes} minutos', style: TextStyle(color: Colors.white.withOpacity(.6))),
                const Spacer(),
                FilledButton.tonal(
                  onPressed: done ? null : () => _completeMission(mission),
                  child: Text(done ? 'Completado' : 'Completar'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _worldPage() {
    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        Text('PULSO WORLD', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w900)),
        const SizedBox(height: 6),
        Text('Una misión compartida por personas de todo el mundo.', style: TextStyle(color: Colors.white.withOpacity(.7))),
        const SizedBox(height: 18),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF173F77), Color(0xFF542E91)]),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.public, size: 42),
              const SizedBox(height: 16),
              const Text('MISIÓN MUNDIAL', style: TextStyle(letterSpacing: 1.4, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text('10.000 gestos positivos', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
              const SizedBox(height: 8),
              const Text('Realiza una pequeña acción positiva y contribuye al objetivo colectivo.'),
              const SizedBox(height: 20),
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [Text('Progreso de ejemplo'), Text('7.842 / 10.000')],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: const LinearProgressIndicator(value: .7842, minHeight: 10, color: Color(0xFF57E3AE), backgroundColor: Colors.white24),
              ),
              const SizedBox(height: 10),
              Text('El contador es ilustrativo. La versión conectada utilizará datos compartidos del servidor.', style: TextStyle(fontSize: 11, color: Colors.white.withOpacity(.7))),
            ],
          ),
        ),
        const SizedBox(height: 18),
        _statCard('Tu país', _country, Icons.flag),
        const SizedBox(height: 12),
        _statCard('Tu contribución en esta demo', 'Aún sin conectar', Icons.volunteer_activism),
      ],
    );
  }

  Widget _rankingPage() {
    final sample = [
      ('1', 'PulsoMaster', 'España', '2.450 XP'),
      ('2', 'LunaAzul', 'México', '2.180 XP'),
      ('3', 'Rayo', 'Argentina', '1.960 XP'),
      ('4', 'Norte', 'Francia', '1.740 XP'),
      ('5', 'Tu posición', _country, '$_xp XP'),
    ];
    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        Text('Clasificaciones', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        Text('Ejemplo visual de rankings. No son usuarios ni resultados reales.', style: TextStyle(color: Colors.white.withOpacity(.65))),
        const SizedBox(height: 18),
        _sectionTitle('RANKING MUNDIAL', 'Temporada 1', null),
        ...sample.map((entry) => Card(
          child: ListTile(
            leading: CircleAvatar(child: Text(entry.$1)),
            title: Text(entry.$2, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(entry.$3),
            trailing: Text(entry.$4, style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
        )),
        const SizedBox(height: 16),
        _sectionTitle('RANKING DE PAÍSES', 'Media por jugador', null),
        Card(
          child: Column(
            children: const [
              ListTile(leading: Text('🇪🇸', style: TextStyle(fontSize: 24)), title: Text('España'), trailing: Text('1.240 pts')),
              Divider(height: 1),
              ListTile(leading: Text('🇲🇽', style: TextStyle(fontSize: 24)), title: Text('México'), trailing: Text('1.180 pts')),
              Divider(height: 1),
              ListTile(leading: Text('🇦🇷', style: TextStyle(fontSize: 24)), title: Text('Argentina'), trailing: Text('1.050 pts')),
            ],
          ),
        ),
      ],
    );
  }

  Widget _profilePage() {
    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        Center(
          child: Column(
            children: [
              const CircleAvatar(radius: 42, child: Icon(Icons.person, size: 46)),
              const SizedBox(height: 12),
              Text(_nickname, style: const TextStyle(fontSize: 23, fontWeight: FontWeight.bold)),
              Text(_country, style: TextStyle(color: Colors.white.withOpacity(.7))),
              const SizedBox(height: 14),
              FilledButton.tonalIcon(onPressed: _editProfile, icon: const Icon(Icons.edit), label: const Text('Editar perfil')),
            ],
          ),
        ),
        const SizedBox(height: 22),
        _statCard('Experiencia', '$_xp XP', Icons.bolt),
        const SizedBox(height: 10),
        _statCard('Nivel', '$_level', Icons.military_tech),
        const SizedBox(height: 10),
        _statCard('Retos completados', '${_completed.length}', Icons.check_circle_outline),
        const SizedBox(height: 20),
        const Text('Insignias', style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        const Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            Chip(avatar: Icon(Icons.star, color: Color(0xFFFFD166)), label: Text('Primer paso')),
            Chip(avatar: Icon(Icons.bolt), label: Text('Energía')),
            Chip(avatar: Icon(Icons.public), label: Text('Explorador')),
          ],
        ),
        const SizedBox(height: 18),
        Text('En esta primera demo los datos se guardan solo mientras la aplicación está abierta. El registro real y la sincronización llegarán al conectar el servidor.', style: TextStyle(color: Colors.white.withOpacity(.65), fontSize: 12)),
      ],
    );
  }

  Widget _statCard(String title, String value, IconData icon) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFF9DA4FF)),
            const SizedBox(width: 12),
            Expanded(child: Text(title, style: TextStyle(color: Colors.white.withOpacity(.75)))),
            Flexible(child: Text(value, textAlign: TextAlign.end, style: const TextStyle(fontWeight: FontWeight.bold))),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title, String action, VoidCallback? onTap) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1))),
          if (onTap != null)
            TextButton(onPressed: onTap, child: Text(action))
          else
            Text(action, style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(.55))),
        ],
      ),
    );
  }

  Widget _worldPreview() {
    return Card(
      child: ListTile(
        leading: const CircleAvatar(child: Icon(Icons.public)),
        title: const Text('10.000 gestos positivos'),
        subtitle: const Text('Misión colectiva mundial'),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () => setState(() => _tab = 2),
      ),
    );
  }
}
