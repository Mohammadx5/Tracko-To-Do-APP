import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final PageController _controller = PageController();
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    context.read<TaskProvider>().loadTasks();
    context.read<TaskProvider>().startAutoRefresh();
  }

  void _finish() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const HomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromRGBO(255, 184, 3, 1),
              Color.fromRGBO(255, 202, 67, 1),
              Color.fromRGBO(33, 158, 188, 1)
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          children: [
            PageView(
              controller: _controller,
              onPageChanged: (i) => setState(() => _currentIndex = i),
              children: [
                _buildPage(
                  'assets/icons/trackoLogo3.png',
                  'Tracko',
                  'نظّم يومك، حقّق أهدافك',
                ),
                _buildPage(
                  'assets/icons/trackoLogo3.png',
                  'سهولة التحكم',
                  'أضف مهامك وتابع إنجازك بضغطة زر',
                ),
                _buildPage(
                  'assets/icons/trackoLogo3.png',
                  'ابدأ الآن',
                  'ادخل إلى قائمة مهامك',
                ),
              ],
            ),
            Positioned(
              bottom: 60,
              left: 0,
              right: 0,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                        3,
                        (index) => AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              height: 8,
                              width: _currentIndex == index ? 24 : 8,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(
                                    _currentIndex == index ? 1 : 0.4),
                                borderRadius: BorderRadius.circular(4),
                              ),
                            )),
                  ),
                  const SizedBox(height: 40),
                  GestureDetector(
                    onHorizontalDragEnd: (details) {
                      if (_currentIndex == 2 && details.primaryVelocity! < 0) {
                        _finish();
                      }
                    },
                    child: _currentIndex == 2
                        ? ElevatedButton(
                            onPressed: _finish,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor:
                                  const Color.fromRGBO(33, 158, 188, 1),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 50, vertical: 15),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30)),
                              elevation: 0,
                            ),
                            child: const Text('دخول',
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold)),
                          )
                        : const SizedBox(
                            height: 50,
                            child: Icon(Icons.arrow_forward_ios,
                                color: Colors.white, size: 20),
                          ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPage(String img, String title, String sub) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(img, width: 130, height: 130),
        const SizedBox(height: 28),
        Text(
          title,
          style: const TextStyle(
            fontSize: 44,
            fontWeight: FontWeight.w900,
            color: Colors.white,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          sub,
          style: const TextStyle(fontSize: 16, color: Colors.white),
        ),
      ],
    );
  }
}
