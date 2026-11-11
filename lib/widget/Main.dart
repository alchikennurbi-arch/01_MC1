import 'package:edu_ws2026_mc101_am/pages/EXplore.dart';
import 'package:edu_ws2026_mc101_am/pages/Information.dart';
import 'package:edu_ws2026_mc101_am/pages/Not.dart';
import 'package:edu_ws2026_mc101_am/pages/home.dart';
import 'package:edu_ws2026_mc101_am/widget/AppDrawer.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class Main extends StatefulWidget {
  const Main({super.key});

  @override
  State<Main> createState() => _MainState();
}

class _MainState extends State<Main> {
  final pages = PageController();
  final mapTouching = ValueNotifier<bool>(false);
  late final VideoPlayerController video;
  bool videoReady = false;

  @override
  void initState() {
    super.initState();
    video = VideoPlayerController.asset("assets/promotional.mp4");
    video.initialize().then((_) {
      if (!mounted) return;
      video.setLooping(true);
      video.setVolume(0);
      video.play();
      setState(() => videoReady = true);
    });
  }

  @override
  void dispose() {
    pages.dispose();
    mapTouching.dispose();
    video.dispose();
    super.dispose();
  }

  void _goToVideoPage() {
    pages.animateToPage(
      1,
      duration: const Duration(milliseconds: 900),
      curve: Curves.easeInOut,
    );
  }

  /// Scroll прогресіне байланған ортақ видео қабаты
  Widget _buildVideoLayer(Size size) {
    return AnimatedBuilder(
      animation: pages,
      builder: (context, _) {
        double p = 0;
        if (pages.hasClients && pages.position.haveDimensions) {
          p = pages.page ?? 0;
        }
        // Information бетіне өткенде видео толық кетеді
        if (!videoReady || p >= 2) return const SizedBox.shrink();

        // 0 -> 1: кішкентай орыннан толық экранға (және кері)
        final t = p.clamp(0.0, 1.0);
        final rect = Rect.lerp(
          HomePage.smallVideoRect(size),
          Offset.zero & size,
          t,
        )!;

        // 1 -> 2: видео бетпен бірге жоғары шығып кетеді
        final dy = p > 1 ? -(p - 1) * size.height : 0.0;

        return Stack(
          children: [
            Positioned.fromRect(
              rect: rect.shift(Offset(0, dy)),
              child: ClipRect(
                child: FittedBox(
                  fit: BoxFit.cover,
                  child: SizedBox(
                    width: video.value.size.width,
                    height: video.value.size.height,
                    child: VideoPlayer(video),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: const Color.fromARGB(255, 6, 25, 21),
      drawer: Appdrawer(
        Home: () {
          pages.jumpToPage(0);
          Navigator.of(context).pop();
        },
        video: () {
          pages.jumpToPage(1);
          Navigator.of(context).pop();
        },
        info: () {
          Navigator.of(context).pop();
          pages.jumpToPage(2);
        },
        Not: () {
          Navigator.of(context).pop();
          pages.jumpToPage(3);
        },
        explore: () {
          Navigator.of(context).pop();
          pages.jumpToPage(4);
        },
      ),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        scrolledUnderElevation: 0,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.transparent,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.language, color: Colors.white),
            color: const Color(0xFF00261C),
            onSelected: (value) {},
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'en',
                child: Text('English', style: TextStyle(color: Colors.white)),
              ),
              const PopupMenuItem(
                value: 'zh',
                child: Text('简体中文', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
          const SizedBox(
            height: 30,
            child: VerticalDivider(color: Colors.white54, width: 1),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.person_outline, color: Colors.white),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Карта басылып тұрғанда PageView скроллы өшеді, сонда карта еркін жылжиды
          ValueListenableBuilder<bool>(
            valueListenable: mapTouching,
            builder: (context, locked, _) => PageView(
              scrollDirection: Axis.vertical,
              controller: pages,
              physics: locked ? const NeverScrollableScrollPhysics() : null,
              children: [
                HomePage(onScrollTap: _goToVideoPage),
                const SizedBox.expand(), // Video беті: видео үстіңгі қабатта көрінеді
                Information(scrollLock: mapTouching),
                Not(),
                Explore(),
              ],
            ),
          ),
          // Видео PageView үстінде, бірақ жанасуды бөгемейді (скролл жұмыс істейді)
          Positioned.fill(child: IgnorePointer(child: _buildVideoLayer(size))),
        ],
      ),
    );
  }
}
