import 'package:flutter/material.dart';

class Information extends StatefulWidget {
  /// Карта басылып тұрғанда true болады. Main осыны тыңдап, PageView-дің
  /// вертикаль скроллын уақытша өшіреді (әйтпесе карта жылжымайды).
  final ValueNotifier<bool>? scrollLock;

  const Information({super.key, this.scrollLock});

  @override
  State<Information> createState() => _InformationState();
}

class _InformationState extends State<Information>
    with SingleTickerProviderStateMixin {
  static const Color _bg = Color(0xFF000E0B);
  static const String _mapAsset = 'assets/images/map.jpg';

  // Карта контентінің өлшемі = viewport * _mapFactor (жылжытуға орын болу үшін)
  static const double _mapFactor = 2.0;

  final TransformationController _mapController = TransformationController();
  late final AnimationController _anim;

  Size _viewport = Size.zero;
  int _pointers = 0;

  // Re-center анимациясына арналған
  Offset _from = Offset.zero;
  Offset _to = Offset.zero;
  double _scale = 1.0;

  Size get _content =>
      Size(_viewport.width * _mapFactor, _viewport.height * _mapFactor);

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..addListener(_onTick);
  }

  @override
  void dispose() {
    _anim.dispose();
    _mapController.dispose();
    super.dispose();
  }

  /// Масштабы s болғанда контент центрі viewport центрімен сәйкес келетін аударым
  Offset _centerTranslation(double s) {
    return Offset(
      _viewport.width / 2 - _content.width / 2 * s,
      _viewport.height / 2 - _content.height / 2 * s,
    );
  }

  Matrix4 _matrix(Offset t, double s) =>
      Matrix4.diagonal3Values(s, s, 1.0)..setTranslationRaw(t.dx, t.dy, 0);

  void _onTick() {
    final t = Curves.easeInOut.transform(_anim.value);
    _mapController.value = _matrix(Offset.lerp(_from, _to, t)!, _scale);
  }

  // Location батырмасы: картаны орталыққа, ҚАЗІРГІ масштабты сақтап, анимациямен қайтарады
  void _resetMapPosition() {
    final m = _mapController.value;
    _scale = m.getMaxScaleOnAxis();
    _from = Offset(m.storage[12], m.storage[13]);
    _to = _centerTranslation(_scale);
    _anim.forward(from: 0);
  }

  void _pointerDown() {
    _pointers++;
    _anim.stop(); // қолмен ұстаса анимацияны тоқтатамыз
    widget.scrollLock?.value = true;
  }

  void _pointerUp() {
    _pointers = (_pointers - 1).clamp(0, 10);
    if (_pointers == 0) widget.scrollLock?.value = false;
  }

  Widget _card({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF062515).withOpacity(0.8),
        borderRadius: BorderRadius.circular(4),
      ),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.viewPaddingOf(context).top + kToolbarHeight;

    return Scaffold(
      backgroundColor: _bg,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(20, topInset, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Visiting Information",
                  style: TextStyle(
                    color: Color.fromARGB(255, 255, 234, 165),
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                _card(
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Opening Hours",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        "08:30-18:00",
                        style: TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                      SizedBox(height: 12),
                      Text(
                        "Last admission time",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        "17:00",
                        style: TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                _card(
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Ticket Reservation",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        "1. Admission: April 1 - October 31 (peak season), 60 yuan / person",
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                          height: 1.4,
                        ),
                      ),
                      SizedBox(height: 6),
                      Text(
                        "2. Admission: November 1 - March 31 (low season), 40 yuan / person",
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Transportation Routes",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      onPressed: _resetMapPosition,
                      icon: const Icon(Icons.my_location, color: Colors.white),
                      tooltip: "Re-center map",
                    ),
                  ],
                ),
              ],
            ),
          ),

          // ================= КАРТА: қалған бос орынның бәрін алады =================
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final vp = Size(constraints.maxWidth, constraints.maxHeight);
                if (vp != _viewport) {
                  _viewport = vp;
                  // Бастапқы күй: карта орталығы көрінеді (пин осында)
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted) {
                      _mapController.value = _matrix(
                        _centerTranslation(1.0),
                        1.0,
                      );
                    }
                  });
                }

                return ClipRect(
                  child: Stack(
                    children: [
                      // Pan + pinch-zoom. Саусақ басылғанда PageView скроллы өшеді.
                      Listener(
                        onPointerDown: (_) => _pointerDown(),
                        onPointerUp: (_) => _pointerUp(),
                        onPointerCancel: (_) => _pointerUp(),
                        child: InteractiveViewer(
                          transformationController: _mapController,
                          constrained: false, // контент viewport-тан үлкен
                          minScale: 1.0,
                          maxScale: 4.0,
                          boundaryMargin: EdgeInsets.zero,
                          child: SizedBox(
                            width: _content.width,
                            height: _content.height,
                            child: Image.asset(
                              _mapAsset,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  Container(
                                    color: Colors.blueGrey.shade900,
                                    alignment: Alignment.center,
                                    child: const Text(
                                      "Map Image (assets/images/map.jpg)",
                                      style: TextStyle(color: Colors.white54),
                                    ),
                                  ),
                            ),
                          ),
                        ),
                      ),

                      // Жоғарғы градиент (фонға сіңу). Жанасуды өткізеді.
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        height: 70,
                        child: IgnorePointer(
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [_bg, _bg.withOpacity(0)],
                              ),
                            ),
                          ),
                        ),
                      ),

                      // Пин: InteractiveViewer-ден ТЫС, сондықтан қозғалмайды әрі масштабталмайды.
                      // Ұшы дәл центрде тұруы үшін жартысына жоғары жылжытылған.
                      Center(
                        child: IgnorePointer(
                          child: Transform.translate(
                            offset: const Offset(0, -20),
                            child: const Icon(
                              Icons.location_pin,
                              color: Color(0xFF0B7A75),
                              size: 40,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
