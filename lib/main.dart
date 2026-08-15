import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'auth_screen.dart';

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
  String _searchQuery = "";

  final String appDownloadUrl = "https://github.com/vrajlimbani-wq/star-india/releases";

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
                  'પ્રોફાઇલ મોડ પસંદ કરો',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 15),
                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Colors.blue,
                    child: Icon(Icons.person, color: Colors.white),
                  ),
                  title: const Text('Personal Profile'),
                  subtitle: const Text('ગ્રાહક સેવાઓ અને સામાન્ય ફીડ'),
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
                  subtitle: const Text('વેપાર, ક્વોટેશન અને પ્રોડક્ટ લિસ્ટિંગ'),
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

  void _openCategoryPage(String title, IconData icon) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CategoryDetailScreen(categoryName: title, categoryIcon: icon),
      ),
    );
  }

  void _copyAppDownloadLink() {
    Clipboard.setData(ClipboardData(text: appDownloadUrl));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Star India ઍપ ડાઉનલોડ લિંક કૉપી થઈ ગઈ છે!'),
        backgroundColor: Colors.green,
      ),
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
            icon: const Icon(Icons.share, color: Colors.white),
            onPressed: _copyAppDownloadLink,
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

  // --- 1. Personal Feed with App Promotion ---
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
                    const Text('Star India પ્લેટફોર્મ પર આપનું સ્વાગત છે', style: TextStyle(color: Colors.grey)),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'સેવાઓ અને કેટેગરીઝ (ટેપ કરીને જુઓ)',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        GridView.count(
          crossAxisCount: 3,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics),
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          children: [
            _buildCategoryItem(Icons.construction, 'કન્સ્ટ્રક્શન'),
            _buildCategoryItem(Icons.format_paint, 'ઇન્ટિરિયર'),
            _buildCategoryItem(Icons.local_shipping, 'ટ્રાન્સપોર્ટ'),
            _buildCategoryItem(Icons.handyman, 'લેબર વર્ક'),
            _buildCategoryItem(Icons.store, 'વેપાર/મટિરિયલ'),
            _buildCategoryItem(Icons.more_horiz, 'અન્ય સેવાઓ'),
          ],
        ),
        const SizedBox(height: 20),
        const Text(
          'Star India ઍપ સ્પેશિયલ',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        
        // --- Star India App Promo Card ---
        Card(
          elevation: 3,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              gradient: const LinearGradient(
                colors: [Color(0xFF1E3A8A), Color(0xFF2563EB)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.stars, color: Colors.amber, size: 28),
                    SizedBox(width: 8),
                    Text(
                      'Star India Official App',
                      style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                const Text(
                  'તમામ વ્યાવસાયિક સેવાઓ, કારીગરો, વેપાર અને મટિરિયલ માટેનું એકમાત્ર વિશ્વસનીય પ્લેટફોર્મ. તમારા મિત્રો અને વેપારીઓ સાથે ઍપ શેર કરો.',
                  style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.4),
                ),
                const SizedBox(height: 15),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.amber,
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        onPressed: _copyAppDownloadLink,
                        icon: const Icon(Icons.download, size: 18),
                        label: const Text('લિંક કૉપી કરો', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: const BorderSide(color: Colors.white),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        onPressed: _copyAppDownloadLink,
                        icon: const Icon(Icons.share, size: 18),
                        label: const Text('શેર કરો'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // --- 2. Business Dashboard ---
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
              onPressed: () => _showAddProductDialog(),
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
        _buildProductCard('Star India સર્વિસ પાર્ટનર', 'ઓલ ઇન્ડિયા', 'Active'),
        _buildProductCard('વેરીફાઇડ બિઝનેસ પ્રોફાઇલ', 'ગુજરાત', 'Active'),
      ],
    );
  }

  // --- 3. Search Screen ---
  Widget _buildSearchScreen() {
    List<String> items = [
      'Star India ઓફિશિયલ ઍપ',
      'કન્સ્ટ્રક્શન સેવાઓ',
      'ઇન્ટિરિયર ડિઝાઇનિંગ',
      'ટ્રાન્સપોર્ટ & લોજિસ્ટિક્સ',
      'કુશળ કારીગરો & લેબર',
      'બિલ્ડિંગ મટિરિયલ સપ્લાય'
    ];

    List<String> filtered = items
        .where((e) => e.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          TextField(
            onChanged: (val) => setState(() => _searchQuery = val),
            decoration: InputDecoration(
              hintText: 'સર્વિસ કે બિઝનેસ શોધો...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              filled: true,
              fillColor: Colors.grey.shade100,
            ),
          ),
          const SizedBox(height: 15),
          Expanded(
            child: ListView.builder(
              itemCount: filtered.length,
              itemBuilder: (context, idx) {
                return ListTile(
                  leading: const Icon(Icons.arrow_forward_ios, size: 16),
                  title: Text(filtered[idx]),
                  onTap: () {
                    _openCategoryPage(filtered[idx], Icons.check_circle_outline);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // --- 4. Notification Screen ---
  Widget _buildNotificationScreen() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: const [
        ListTile(
          leading: CircleAvatar(
            backgroundColor: Colors.indigo,
            child: Icon(Icons.notifications, color: Colors.white),
          ),
          title: Text('Star India માં આપનું સ્વાગત છે!'),
          subtitle: Text('તમારી પ્રોફાઇલ સેટઅપ સફળ થઈ ગઈ છે.'),
        ),
      ],
    );
  }

  // --- 5. Profile Screen ---
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
              Text('ચાલુ પ્રોફાઇલ: $_activeProfile', style: const TextStyle(color: Colors.grey)),
            ],
          ),
        ),
        const SizedBox(height: 25),
        ListTile(
          leading: const Icon(Icons.swap_horiz, color: Colors.blue),
          title: const Text('પ્રોફાઇલ મોડ બદલો'),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: _showProfileSwitchModal,
        ),
        ListTile(
          leading: const Icon(Icons.share, color: Colors.green),
          title: const Text('ઍપ ડાઉનલોડ લિંક શેર કરો'),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: _copyAppDownloadLink,
        ),
        const Divider(),
        ListTile(
          leading: const Icon(Icons.logout, color: Colors.red),
          title: const Text('લોગઆઉટ કરો', style: TextStyle(color: Colors.red)),
          onTap: () async {
            await FirebaseAuth.instance.signOut();
            if (mounted) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const AuthScreen()),
              );
            }
          },
        ),
      ],
    );
  }

  Widget _buildCategoryItem(IconData icon, String label) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(10),
      elevation: 1,
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () => _openCategoryPage(label, icon),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: const Color(0xFF1E3A8A), size: 30),
              const SizedBox(height: 6),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ],
          ),
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
          border: Border.all(color: color.withOpacity(
