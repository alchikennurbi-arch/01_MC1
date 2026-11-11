import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Not extends StatefulWidget {
  const Not({super.key});

  @override
  State<Not> createState() => _NotState();
}

class _NotState extends State<Not> {
  static const Color _bg = Color(0xFF000E0B);
  static const Color _bgGreen = Color(0xFF1D5640);

  List<Map<String, dynamic>> relics = [];
  bool isLoading = true;
  int _currentIndex = 0;

  // 0.6: ортадағы сурет үлкен, көршілері экран шетінде сәл көрінеді
  late final PageController _pageController = PageController(
    viewportFraction: 0.6,
  );

  @override
  void initState() {
    super.initState();
    _loadJsonData();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadJsonData() async {
    try {
      final String response = await rootBundle.loadString(
        'assets/data/collections.json',
      );
      dynamic data = json.decode(response);

      // JSON тізім болуы да, ішінде тізімі бар объект болуы да мүмкін
      if (data is Map) {
        data = data.values.firstWhere((v) => v is List, orElse: () => []);
      }
      final list = (data as List)
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();

      if (!mounted) return;
      setState(() {
        relics = list;
        isLoading = false;
      });
    } catch (e) {
      debugPrint("JSON оқу қатесі: $e");
      if (!mounted) return;
      setState(() => isLoading = false);
    }
  }

  // Кілт аттары әртүрлі болуы мүмкін, сондықтан бірнешеуін тексереміз
  String _field(Map<String, dynamic> item, List<String> keys) {
    for (final k in keys) {
      final v = item[k];
      if (v == null) continue;
      if (v is List && v.isNotEmpty) return v.first.toString();
      final s = v.toString();
      if (s.isNotEmpty) return s;
    }
    return "";
  }

  String _name(int i) => _field(relics[i], ['name', 'title', 'relicName']);
  String _desc(int i) =>
      _field(relics[i], ['description', 'desc', 'content', 'detail']);
  String _image(int i) =>
      _field(relics[i], ['image', 'img', 'picture', 'cover', 'src', 'url']);

  Widget _buildImage(String path) {
    final fallback = const Center(
      child: Icon(Icons.museum, color: Colors.white54, size: 50),
    );
    if (path.isEmpty) return fallback;
    if (path.startsWith('http')) {
      return Image.network(path, fit: BoxFit.contain);
    }
    final p = path.startsWith('assets/')
        ? path
        : path.startsWith('images/')
        ? 'assets/$path'
        : 'assets/images/$path';
    return Image.asset(
      p,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) => fallback,
    );
  }

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.sizeOf(context).height;
    // final topInset = MediaQuery.viewPaddingOf(context).top + kToolbarHeight;

    return Scaffold(
      backgroundColor: _bg,
      body: Container(
        // Төменге қарай қараңғыдан жасылға өтетін градиент
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [_bg, _bg, _bgGreen],
            stops: [0.0, 0.55, 1.0],
          ),
        ),
        child: isLoading
            ? const Center(
                child: CircularProgressIndicator(color: Colors.white),
              )
            : relics.isEmpty
            ? const Center(
                child: Text("No data", style: TextStyle(color: Colors.white)),
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // SizedBox(height: topInset - 1),
                  SizedBox(height: 100), // 1. Тақырып
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      "Not to be missed",
                      style: TextStyle(
                        color: Color.fromARGB(255, 255, 234, 165),
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  // 2. Көлденең карусель
                  Expanded(
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: relics.length,
                      onPageChanged: (i) => setState(() => _currentIndex = i),
                      itemBuilder: (context, index) {
                        return AnimatedBuilder(
                          animation: _pageController,
                          builder: (context, child) {
                            double page = _currentIndex.toDouble();
                            if (_pageController.hasClients &&
                                _pageController.position.haveDimensions) {
                              page = _pageController.page ?? page;
                            }
                            // 0 = ортада, 1 = көрші
                            final d = (page - index).abs().clamp(0.0, 1.0);

                            return Center(
                              child: Opacity(
                                opacity: 1.0 - 0.65 * d, // жартылай мөлдір
                                child: Transform.scale(
                                  scale: 1.0 - 0.4 * d, // кішірейген
                                  child: child,
                                ),
                              ),
                            );
                          },
                          child: SizedBox(
                            height: h * 0.30,
                            width: double.infinity,
                            child: _buildImage(_image(index)),
                          ),
                        );
                      },
                    ),
                  ),

                  // 3. Атауы мен сипаттамасы (ауысқанда жұмсақ fade)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: SizedBox(
                      height: 130,
                      width: double.infinity,
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        // alignment: Alignment.topLeft,
                        child: Column(
                          key: ValueKey(_currentIndex),
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _name(_currentIndex),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _desc(_currentIndex),
                              maxLines: 5,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white54,
                                fontSize: 12,
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // 4. Learn more
                  Center(
                    child: OutlinedButton(
                      onPressed: () {},
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.white, width: 1),
                        minimumSize: const Size(110, 38),
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.zero,
                        ),
                      ),
                      child: const Text(
                        "Learn more",
                        style: TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ),
                  ),
                  SizedBox(height: h * 0.05),
                ],
              ),
      ),
    );
  }
}
