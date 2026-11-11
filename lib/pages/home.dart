import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  // "Scroll to see more" басылғанда Main осы арқылы Video бетіне скролл жасайды
  final VoidCallback? onScrollTap;

  const HomePage({Key? key, this.onScrollTap}) : super(key: key);

  // ---- Main-мен ортақ геометрия (видеоның бастапқы орнын есептеу үшін) ----
  static const List<String> titleLines = [
    "Experience",
    "The",
    "Romantic",
    "Culture",
  ];
  static const double titleLeft = 28;
  static const double titleLineHeight = 70;
  static const TextStyle titleStyle = TextStyle(
    color: Colors.white,
    fontSize: 56,
    fontWeight: FontWeight.w700,
    height: 70 / 56,
    letterSpacing: -0.5,
  );

  static double titleTop(double h) => h * 0.218;

  /// Бастапқы кішкентай видеоның орны: 2-ші жолдың ("The") оң жағында.
  static Rect smallVideoRect(Size size) {
    double theWidth = 0;
    for (final ch in "The".split('')) {
      final tp = TextPainter(
        text: TextSpan(text: ch, style: titleStyle),
        textDirection: TextDirection.ltr,
      )..layout();
      theWidth += tp.width;
    }
    const double vw = 96, vh = 54;
    final left = titleLeft + theWidth + 12;
    final top =
        titleTop(size.height) + titleLineHeight + (titleLineHeight - vh) / 2;
    return Rect.fromLTWH(left, top, vw, vh);
  }

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  late AnimationController _textController;
  late AnimationController _buttonController;

  @override
  void initState() {
    super.initState();

    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 7000),
    );

    _buttonController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _textController.forward();

    // Тақырып бітіп болған соң батырма анимациясы басталады
    _textController.addListener(() {
      if (_textController.value > 0.75 &&
          !_buttonController.isAnimating &&
          !_buttonController.isCompleted) {
        _buttonController.forward();
      }
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    _buttonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final h = size.height;
    final k = size.width / 360;

    final double btnW = 168 * k;
    final double btnH = 42 * k;

    return Scaffold(
      backgroundColor: const Color(0xFF000E0B),
      body: Stack(
        children: [
          // ================= ТАҚЫРЫП =================
          Positioned(
            top: HomePage.titleTop(h),
            left: HomePage.titleLeft,
            right: 28,
            child: AnimatedBuilder(
              animation: _textController,
              builder: (context, _) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: List.generate(HomePage.titleLines.length, (i) {
                    final word = HomePage.titleLines[i];
                    return Row(
                      mainAxisSize: MainAxisSize.min,
                      children: List.generate(word.length, (j) {
                        // келесі жол алдыңғы жолдың 3-ші әрпінен бастап шығады
                        final double startDelay = 0.3 + (i * 3 + j) * 0.02;
                        final double endDelay = startDelay + 0.15;

                        final rawValue =
                            (_textController.value - startDelay) /
                            (endDelay - startDelay);
                        final t = Curves.easeOut.transform(
                          rawValue.clamp(0.0, 1.0),
                        );

                        return Opacity(
                          opacity: t,
                          child: Transform.translate(
                            offset: Offset(0, 10 * (1 - t)),
                            child: ShaderMask(
                              shaderCallback: (bounds) => const LinearGradient(
                                colors: [
                                  Colors.white,
                                  Color.fromARGB(201, 95, 141, 125),
                                ],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ).createShader(bounds),
                              child: Text(word[j], style: HomePage.titleStyle),
                            ),
                          ),
                        );
                      }),
                    );
                  }),
                );
              },
            ),
          ),

          // Видео мұнда ЖОҚ: ол Main-де ортақ қабат болып тұр.

          // ================= БАТЫРМА =================
          Positioned(
            bottom: h * 0.0875,
            left: 0,
            right: 0,
            child: Center(
              child: AnimatedBuilder(
                animation: _buttonController,
                builder: (context, _) {
                  final v = _buttonController.value;

                  final expand = Curves.easeOutQuad.transform(v);
                  final currentWidth = 2.0 + (btnW - 2.0) * expand;
                  final textOpacity = v > 0.6 ? (v - 0.6) / 0.4 : 0.0;

                  return GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: widget.onScrollTap,
                    child: Container(
                      width: currentWidth,
                      height: btnH,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.white, width: 1),
                      ),
                      child: Opacity(
                        opacity: textOpacity.clamp(0.0, 1.0),
                        child: const Text(
                          "Scroll to see more",
                          maxLines: 1,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
