import 'package:flutter/material.dart';
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
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1E3A8A),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      home: const MainHomeScreen(),
    );
  }
}

class MainHomeScreen extends StatefulWidget {
  final String userName;
  final String profileType;

  const MainHomeScreen({
    super.key,
    this.userName = "Vraj Limbani",
    this.profileType = "Personal",
  });

  @override
  State<MainHomeScreen> createState() => _MainHomeScreenState();
}

class _MainHomeScreenState extends State<MainHomeScreen> {
  int _currentIndex = 0;

  void _openCreatePostModal() {
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
              children: [
                const Text(
                  'નવી પોસ્ટ / કન્ટેન્ટ ઉમેરો',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                ),
                const SizedBox(height: 16),
                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Colors.blue,
                    child: Icon(Icons.post_add, color: Colors.white),
                  ),
                  title: const Text('Create Post / Tweet (X & FB)'),
                  onTap: () => Navigator.pop(context),
                ),
                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Colors.red,
                    child: Icon(Icons.video_call, color: Colors.white),
                  ),
                  title: const Text('Upload Reel / Video (TikTok & Insta)'),
                  onTap: () => Navigator.pop(context),
                ),
                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Colors.green,
                    child: Icon(Icons.history_toggle_off, color: Colors.white),
                  ),
                  title: const Text('Add Status / Story (WhatsApp)'),
                  onTap: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPostAction(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey.shade600),
        if (label.isNotEmpty) ...[
          const SizedBox(width: 4),
          Text(label, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
        ],
      ],
    );
  }

  Widget _buildReelAction(IconData icon, String count, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 4),
        Text(count, style: const TextStyle(color: Colors.white, fontSize: 12)),
      ],
    );
  }

  Widget _buildMyStoryItem() {
    return Container(
      margin: const EdgeInsets.only(right: 12),
      child: const Column(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: Colors.grey,
                child: Icon(Icons.person, color: Colors.white),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: CircleAvatar(
                  radius: 9,
                  backgroundColor: Colors.blue,
                  child: Icon(Icons.add, size: 14, color: Colors.white),
                ),
              ),
            ],
          ),
          SizedBox(height: 4),
          Text('Your Story', style: TextStyle(fontSize: 11)),
        ],
      ),
    );
  }

  Widget _buildStoryItem(String title, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.only(right: 12),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(2.5),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.pink, width: 2),
            ),
            child: CircleAvatar(
              radius: 26,
              backgroundColor: color,
              child: Icon(icon, color: Colors.white, size: 22),
            ),
          ),
          const SizedBox(height: 4),
          Text(title, style: const TextStyle(fontSize: 11)),
        ],
      ),
    );
  }

  Widget _buildTwitterPost(String name, String handle, String text, String likes, String comments) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const CircleAvatar(
                  radius: 18,
                  backgroundColor: Colors.black87,
                  child: Icon(Icons.tag, color: Colors.white, size: 18),
                ),
                const SizedBox(width: 8),
                Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(width: 6),
                Text(handle, style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
            const SizedBox(height: 8),
            Text(text, style: const TextStyle(fontSize: 14, height: 1.3)),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildPostAction(Icons.chat_bubble_outline, comments),
                _buildPostAction(Icons.repeat, 'Repost'),
                _buildPostAction(Icons.favorite_border, likes),
                _buildPostAction(Icons.share_outlined, ''),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMediaPost(String name, String location, String text, String likes, String comments) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            leading: const CircleAvatar(
              backgroundColor: Color(0xFF1E3A8A),
              child: Icon(Icons.person, color: Colors.white),
            ),
            title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(location, style: const TextStyle(fontSize: 11)),
            trailing: const Icon(Icons.more_vert),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            child: Text(text),
          ),
          Container(
            height: 180,
            margin: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.blue.shade900,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Center(
              child: Icon(Icons.image, size: 60, color: Colors.white54),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: Row(
              children: [
                IconButton(icon: const Icon(Icons.favorite_border, color: Colors.red), onPressed: () {}),
                IconButton(icon: const Icon(Icons.chat_bubble_outline), onPressed: () {}),
                IconButton(icon: const Icon(Icons.send_outlined), onPressed: () {}),
                const Spacer(),
                IconButton(icon: const Icon(Icons.bookmark_border), onPressed: () {}),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCombinedFeed() {
    return ListView(
      children: [
        Container(
          height: 105,
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
          ),
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              const SizedBox(width: 12),
              _buildMyStoryItem(),
              _buildStoryItem('Star News', Icons.campaign, Colors.blue),
              _buildStoryItem('Trending', Icons.local_fire_department, Colors.orange),
              _buildStoryItem('Gujarat', Icons.location_city, Colors.green),
              _buildStoryItem('Tech', Icons.computer, Colors.purple),
            ],
          ),
        ),
        Card(
          margin: const EdgeInsets.all(8),
          elevation: 1,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                const CircleAvatar(
                  backgroundColor: Color(0xFF1E3A8A),
                  child: Icon(Icons.person, color: Colors.white),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: InkWell(
                    onTap: _openCreatePostModal,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        "તમારા વિચારો પોસ્ટ કરો (Post / Tweet)...",
                        style: TextStyle(color: Colors.grey, fontSize: 13),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        _buildTwitterPost(
          'Star India Official',
          '@starindia',
          'નવું ઓલ-ઇન-વન સોશિયલ મીડિયા હબ હવે તૈયાર છે! તમામ સોશિયલ મીડિયા ફીચર્સ એક જ જગ્યાએ. 🚀 #StarIndia #NextGenApp',
          '1.5K',
          '240',
        ),
        _buildMediaPost(
          widget.userName,
          'અમદાવાદ, ગુજરાત',
          'Star India પ્લેટફોર્મ પર આપનું સ્વાગત છે! કન્ટેન્ટ શેર કરો અને કનેક્ટ થાઓ.',
          '4.2K',
          '180',
        ),
      ],
    );
  }

  Widget _buildReelsShortsFeed() {
    return PageView.builder(
      scrollDirection: Axis.vertical,
      itemCount: 5,
      itemBuilder: (context, index) {
        return Container(
          color: Colors.black,
          child: Stack(
            children: [
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.play_circle_outline, size: 80, color: Colors.white70),
                    const SizedBox(height: 12),
                    Text(
                      'Star Reel / Short #${index + 1}',
                      style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const Text('સ્વાઇપ કરીને આગળની રીલ જુઓ', style: TextStyle(color: Colors.white60)),
                  ],
                ),
              ),
              Positioned(
                bottom: 30,
                left: 16,
                right: 70,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '@star_creator_${index + 1}',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Star India શોર્ટ વિડીયો પ્લેટફોર્મ #Viral #TrendingReels #StarIndia',
                      style: TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                  ],
                ),
              ),
              Positioned(
                bottom: 40,
                right: 16,
                child: Column(
                  children: [
                    _buildReelAction(Icons.favorite, '12.4K', Colors.red),
                    const SizedBox(height: 16),
                    _buildReelAction(Icons.comment, '450', Colors.white),
                    const SizedBox(height: 16),
                    _buildReelAction(Icons.share, 'Share', Colors.white),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTrendingExplore() {
    List<Map<String, String>> trends = [
      {'tag': '#StarIndiaApp', 'posts': '52.4K Posts', 'category': 'Trending in Gujarat'},
      {'tag': '#AllInOnePlatform', 'posts': '31.2K Posts', 'category': 'Technology'},
      {'tag': '#DigitalIndia', 'posts': '140K Posts', 'category': 'India Trends'},
      {'tag': '#SocialMedia2026', 'posts': '22.8K Posts', 'category': 'Trending'},
    ];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        TextField(
          decoration: InputDecoration(
            hintText: 'સર્ચ કરો ટ્રેન્ડ્સ, પ્રોફાઇલ કે હેશટેગ...',
            prefixIcon: const Icon(Icons.search),
            filled: true,
            fillColor: Colors.grey.shade100,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(25), borderSide: BorderSide.none),
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'Trends for you (X / Twitter)',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        ...trends.map((t) => ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(t['tag']!, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E3A8A))),
          subtitle: Text('${t['category']} • ${t['posts']}'),
          trailing: const Icon(Icons.more_vert),
        )),
      ],
    );
  }

  Widget _buildWhatsAppChats() {
    List<Map<String, String>> chats = [
      {'name': 'Star India Support', 'msg': 'નમસ્તે, આપનું એકાઉન્ટ સક્રિય થઈ ગયું છે.', 'time': '10:45 AM', 'unread': '1'},
      {'name': 'ગુજરાત ક્રિએટર્સ ગ્રૂપ', 'msg': 'નવી પોસ્ટ શેર કરવામાં આવી છે.', 'time': '09:12 AM', 'unread': '3'},
      {'name': 'Social Updates', 'msg': 'તમારી Reel ટ્રેન્ડિંગમાં છે.', 'time': 'Yesterday', 'unread': '0'},
    ];

    return ListView.separated(
      itemCount: chats.length,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final c = chats[index];
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: const Color(0xFF1E3A8A),
            child: Text(c['name']![0], style: const TextStyle(color: Colors.white)),
          ),
          title: Text(c['name']!, style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text(c['msg']!, maxLines: 1, overflow: TextOverflow.ellipsis),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(c['time']!, style: const TextStyle(fontSize: 11, color: Colors.grey)),
              if (c['unread'] != '0')
                Container(
                  margin: const EdgeInsets.only(top: 4),
                  padding: const EdgeInsets.all(5),
                  decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle),
                  child: Text(c['unread']!, style: const TextStyle(color: Colors.white, fontSize: 10)),
                ),
            ],
          ),
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('${c['name']} સાથે ચેટ શરૂ કરો')),
            );
          },
        );
      },
    );
  }

  Widget _buildStatColumn(String count, String label) {
    return Column(
      children: [
        Text(count, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }

  Widget _buildInstagramProfile() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          children: [
            const CircleAvatar(
              radius: 40,
              backgroundColor: Color(0xFF1E3A8A),
              child: Icon(Icons.person, size: 50, color: Colors.white),
            ),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildStatColumn('12', 'Posts'),
                  _buildStatColumn('1.5K', 'Followers'),
                  _buildStatColumn('320', 'Following'),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(widget.userName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const Text('Official Star India Creator', style: TextStyle(color: Colors.grey)),
        const Text('🚀 All-in-One Social Experience Hub'),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () {},
                child: const Text('Edit Profile'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton(
                onPressed: () {},
                child: const Text('Share Profile'),
              ),
            ),
          ],
        ),
        const Divider(height: 30),
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

  Widget _getBody() {
    switch (_currentIndex) {
      case 0:
        return _buildCombinedFeed();
      case 1:
        return _buildReelsShortsFeed();
      case 2:
        return _buildTrendingExplore();
      case 3:
        return _buildWhatsAppChats();
      case 4:
        return _buildInstagramProfile();
      default:
        return _buildCombinedFeed();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: co
