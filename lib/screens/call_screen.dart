import 'package:flutter/material.dart';

class CallScreen extends StatefulWidget {
  final String targetName;
  final bool isVideoCall;
  final String currentLanguage; // 'en' or 'gu'

  const CallScreen({
    super.key,
    required this.targetName,
    required this.isVideoCall,
    this.currentLanguage = 'en',
  });

  @override
  State<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {
  bool _isMuted = false;
  bool _isSpeakerOn = true;
  bool _isVideoOff = false;
  bool _isConnected = false;

  @override
  void initState() {
    super.initState();
    // ૨ સેકન્ડમાં કોલ કનેક્ટ થાય તેવો લાઈવ અનુભવ
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isConnected = true;
        });
      }
    });
  }

  String _getText(String enText, String guText) {
    return widget.currentLanguage == 'gu' ? guText : enText;
  }

  @override
  Widget build(BuildContext context) {
    final statusText = _isConnected
        ? _getText('Call Connected', 'કૉલ જોડાઈ ગયો છે')
        : (widget.isVideoCall
            ? _getText('Connecting Video Call...', 'વિડિઓ કૉલ કનેક્ટ થઈ રહ્યો છે...')
            : _getText('Connecting Audio Call...', 'ઓડિયો કૉલ કનેક્ટ થઈ રહ્યો છે...'));

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 40),
            Text(
              widget.targetName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              statusText,
              style: TextStyle(
                color: _isConnected ? Colors.greenAccent : Colors.white70,
                fontSize: 16,
              ),
            ),
            const Spacer(),

            // મિડલ એરિયા: વીડિયો અથવા પ્રોફાઇલ અવતાર
            Center(
              child: widget.isVideoCall && !_isVideoOff
                  ? Container(
                      width: 260,
                      height: 360,
                      decoration: BoxDecoration(
                        color: Colors.black45,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white24),
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.videocam_rounded, size: 60, color: Colors.white70),
                            const SizedBox(height: 12),
                            Text(
                              _getText('Live Video Feed Active', 'લાઇવ વિડિઓ શરૂ છે'),
                              style: const TextStyle(color: Colors.white60, fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                    )
                  : CircleAvatar(
                      radius: 65,
                      backgroundColor: const Color(0xFF1E3A8A),
                      child: Text(
                        widget.targetName.isNotEmpty ? widget.targetName[0].toUpperCase() : 'U',
                        style: const TextStyle(fontSize: 48, color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
            ),

            const Spacer(),

            // નીચેના કંટ્રોલ બટન્સ (Mute, Camera/Speaker, End Call)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
              decoration: const BoxDecoration(
                color: Color(0xFF1E293B),
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    icon: Icon(_isMuted ? Icons.mic_off : Icons.mic, color: Colors.white, size: 28),
                    style: IconButton.styleFrom(backgroundColor: _isMuted ? Colors.red.shade400 : Colors.white24),
                    onPressed: () {
                      setState(() {
                        _isMuted = !_isMuted;
                      });
                    },
                  ),
                  if (widget.isVideoCall)
                    IconButton(
                      icon: Icon(_isVideoOff ? Icons.videocam_off : Icons.videocam, color: Colors.white, size: 28),
                      style: IconButton.styleFrom(backgroundColor: _isVideoOff ? Colors.red.shade400 : Colors.white24),
                      onPressed: () {
                        setState(() {
                          _isVideoOff = !_isVideoOff;
                        });
                      },
                    )
                  else
                    IconButton(
                      icon: Icon(_isSpeakerOn ? Icons.volume_up : Icons.volume_down, color: Colors.white, size: 28),
                      style: IconButton.styleFrom(backgroundColor: _isSpeakerOn ? const Color(0xFF1E3A8A) : Colors.white24),
                      onPressed: () {
                        setState(() {
                          _isSpeakerOn = !_isSpeakerOn;
                        });
                      },
                    ),
                  IconButton(
                    icon: const Icon(Icons.call_end, color: Colors.white, size: 32),
                    style: IconButton.styleFrom(backgroundColor: Colors.red, padding: const EdgeInsets.all(12)),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
