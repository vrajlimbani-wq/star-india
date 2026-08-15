import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyAFWVCmLEW-3vmjQys5p4yj3JkjJJho2Cc",
      appId: "1:219020282945:android:82be9457eb99719125cac0",
      messagingSenderId: "219020282945",
      projectId: "star-india-a377f",
      storageBucket: "star-india-a377f.firebasestorage.app",
    ),
  );
  
  runApp(const StarIndiaApp());
}

class StarIndiaApp extends StatelessWidget {
  const StarIndiaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Star India',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1E3A8A)),
        useMaterial3: true,
      ),
      home: const MainHomeScreen(
        userName: "Vraj Limbani",
        initialProfile: "Personal",
      ),
    );
  }
}

class MainHomeScreen extends StatefulWidget {
  final String userName;
  final String initialProfile;

  const MainHomeScreen({
    super.key,
    required this.userName,
    required this.initialProfile,
  });

  @override
  State<MainHomeScreen> createState() => _MainHomeScreenState();
}

class _MainHomeScreenState extends State<MainHomeScreen> {
  int _currentIndex = 0;
  late String _activeProfile;

  @override
  void initState() {
    super.initState();
    _activeProfile = widget.initialProfile;
  }

  void _showProfileSwitchModal() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'પ્રોફાઇલ પસંદ કરો (Switch Profile)',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 15),
                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Colors.blue,
                    child: Icon(Icons.person, color: Colors.white),
                  ),
                  title: const Text('Personal Profile'),
                  subtitle: const Text('વ્યક્તિગત સેવાઓ અને ફીડ'),
                  trailing: _activeProfile == 'Personal'
                      ? const Icon(Icons.check_circle, color: Colors.green)
                      : null,
                  onTap: () {
                    setState(() => _activeProfile = 'Personal');
                    Navigator.pop(context);
                  },
                ),
                const Divider(),
                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Colors.orange,
                    child: Icon(Icons.business, color: Colors.white),
                  ),
                  title: const Text('Business Profile'),
                  subtitle: const Text('બિઝનેસ ડેશબોર્ડ, પ્રોડક્ટ્સ અને સર્વિસિસ'),
                  trailing: _activeProfile == 'Business'
                      ? const Icon(Icons.check_circle, color: Colors.green)
                      : null,
                  onTap: () {
                    setState(() => _activeProfile = 'Business');
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E3A8A),
        elevation: 2,
        title: GestureDetector(
          onTap: _showProfileSwitchModal,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.18),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _activeProfile == 'Personal' ? Icons.person : Icons.business_center,
                  color: Colors.amber,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Star India [$_activeProfile]',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Icon(Icons.arrow_drop_down, color: Colors.white),
              ],
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_scanner, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: _getBodyWidget(),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home, color: Color(0xFF1E3A8A)),
            label: 'હોમ',
          ),
          NavigationDestination(
            icon: Icon(Icons.search_outlined),
            selectedIcon: Icon(Icons.search, color: Color(0xFF1E3A8A)),
            label: 'સર્ચ',
          ),
          NavigationDestination(
            icon: Icon(Icons.notifications_outlined),
            selectedIcon: Icon(Icons.notifications, color: Color(0xFF1E3A8A)),
            label: 'નોટિફિકેશન',
          ),
          NavigationDestination(
            icon: Icon(Icons.account_circle_outlined),
            selectedIcon: Icon(Icons.account_circle, color: Color(0xFF1E3A8A)),
            label: 'પ્રોફાઇલ',
          ),
        ],
      ),
    );
  }

  Widget _getBodyWidget() {
    switch (_currentIndex) {
      case 0:
        return _activeProfile == 'Personal'
            ? _buildPersonalFeed()
            : _buildBusinessDashboard();
      case 1:
        return _buildSearchScreen();
      case 2:
        return _buildNotificationScreen();
      case 3:
        return _buildProfileScreen();
      default:
        return _buildPersonalFeed();
    }
  }

  // 1. Personal Feed
  Widget _buildPersonalFeed() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          color: Colors.blue.shade50,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 25,
                  backgroundColor: Color(0xFF1E3A8A),
                  child: Icon(Icons.person, color: Colors.white, size: 30),
                ),
                const SizedBox(width: 14),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'નમસ્તે, ${widget.userName}',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const Text('પર્સનલ ફીડ અને ઉપલબ્ધ સેવાઓ', style: TextStyle(color: Colors.grey)),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'સેવાઓ અને કેટેગરીઝ',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        GridView.count(
          crossAxisCount: 3,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          children: [
            _buildCategoryItem(Icons.construction, 'કન્સ્ટ્રક્શન'),
            _buildCategoryItem(Icons.format_paint, 'ઇન્ટિરિયર'),
            _buildCategoryItem(Icons.local_shipping, 'ટ્રાન્સપોર્ટ'),
            _buildCategoryItem(Icons.handyman, 'લેબર વર્ક'),
            _buildCategoryItem(Icons.store, 'વેપાર/મટિરિયલ'),
            _buildCategoryItem(Icons.more_horiz, 'અન્ય'),
          ],
        ),
        const SizedBox(height: 20),
        const Text(
          'તાજેતરની અપડેટ્સ અને પોસ્ટ્સ',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        _buildFeedCard(
          'સ્ટાર ઇન્ડિયા કન્સ્ટ્રક્શન અપડેટ',
          'અમદાવાદ વિસ્તારમાં નવા પ્રોજેક્ટ માટે ઉપલબ્ધ પ્લાનિંગ અને કોન્ટ્રાક્ટ વર્ક.',
          Icons.apartment,
        ),
      ],
    );
  }

  // 2. Business Dashboard
  Widget _buildBusinessDashboard() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF1E3A8A), Color(0xFF3B82F6)],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'બિઝનેસ ડેશબોર્ડ (Business Hub)',
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 6),
              Text(
                'તમારા ઓર્ડર, ઇન્ક્વાયરી અને પ્રોડક્ટ લિસ્ટિંગ અહીંથી મેનેજ કરો.',
                style: TextStyle(color: Colors.white70, fontSize: 13),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            _buildStatCard('કુલ ઇન્ક્વાયરી', '12', Colors.blue),
            const SizedBox(width: 10),
            _buildStatCard('એક્ટિવ લિસ્ટિંગ', '5', Colors.green),
            const SizedBox(width: 10),
            _buildStatCard('પ્રોફાઇલ વ્યુઝ', '140', Colors.orange),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'તમારી પ્રોડક્ટ્સ અને સર્વિસિસ',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            ),
            ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.add, size: 16),
              label: const Text('નવું ઉમેરો'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E3A8A),
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        _buildProductCard('રેસિડેન્શિયલ કન્સ્ટ્રક્શન સર્વિસ', 'અમદાવાદ', 'Active'),
        _buildProductCard('સિવિલ & ઇન્ટિરિયર વર્ક પેકેજ', 'નરોડા / નિકોલ', 'Active'),
      ],
    );
  }

  // 3. Search Screen
  Widget _buildSearchScreen() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          TextField(
            decoration: InputDecoration(
              hintText: 'સર્વિસ, પ્રોડક્ટ અથવા બિઝનેસ શોધો...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              filled: true,
              fillColor: Colors.grey.shade100,
            ),
          ),
          const SizedBox(height: 20),
          const Center(child: Text('શોધવા માટે કીવર્ડ દાખલ કરો')),
        ],
      ),
    );
  }

  // 4. Notification Screen
  Widget _buildNotificationScreen() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: const [
        ListTile(
          leading: CircleAvatar(child: Icon(Icons.notifications_active)),
          title: Text('સ્ટાર ઇન્ડિયામાં તમારું સ્વાગત છે!'),
          subtitle: Text('તમારી પ્રોફાઇલ સફળતાપૂર્વક તૈયાર થઈ ગઈ છે.'),
        ),
        Divider(),
      ],
    );
  }

  // 5. Profile Screen
  Widget _buildProfileScreen() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Center(
          child: Column(
            children: [
              const CircleAvatar(
                radius: 40,
                backgroundColor: Color(0xFF1E3A8A),
                child: Icon(Icons.person, size: 50, color: Colors.white),
              ),
              const SizedBox(height: 10),
              Text(
                widget.userName,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              Text('મોડ: $_activeProfile', style: const TextStyle(color: Colors.grey)),
            ],
          ),
        ),
        const SizedBox(height: 20),
        ListTile(
          leading: const Icon(Icons.edit),
          title: const Text('પ્રોફાઇલ એડિટ કરો'),
          onTap: () {},
        ),
        ListTile(
          leading: const Icon(Icons.swap_horiz),
          title: const Text('પ્રોફાઇલ સ્વિચ કરો'),
          onTap: _showProfileSwitchModal,
        ),
        ListTile(
          leading: const Icon(Icons.logout, color: Colors.red),
          title: const Text('લોગઆઉટ', style: TextStyle(color: Colors.red)),
          onTap: () {},
        ),
      ],
    );
  }

  // Helper Widgets
  Widget _buildCategoryItem(IconData icon, String label) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: const Color(0xFF1E3A8A), size: 28),
          const SizedBox(height: 6),
          Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildFeedCard(String title, String desc, IconData icon) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: const Color(0xFF1E3A8A)),
                const SizedBox(width: 8),
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ],
            ),
            const SizedBox(height: 8),
            Text(desc, style: const TextStyle(color: Colors.black87)),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
            const SizedBox(height: 4),
            Text(title, style: const TextStyle(fontSize: 11, color: Colors.black54)),
          ],
        ),
      ),
    );
  }

  Widget _buildProductCard(String title, String location, String status) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        leading: const Icon(Icons.business_center, color: Color(0xFF1E3A8A)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(location),
        trailing: Chip(
          label: Text(status, style: const TextStyle(color: Colors.white, fontSize: 11)),
          backgroundColor: Colors.green,
          padding: EdgeInsets.zero,
        ),
      ),
    );
  }
}
