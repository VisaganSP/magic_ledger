import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _rotateController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotateAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize animations
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _rotateController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _scaleAnimation = CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    );

    _rotateAnimation = CurvedAnimation(
      parent: _rotateController,
      curve: Curves.easeInOut,
    );

    // Start animations
    _startAnimations();

    // Navigate to home after delay
    Future.delayed(const Duration(seconds: 3), () {
      Get.offAllNamed('/home');
    });
  }

  void _startAnimations() {
    _scaleController.forward();
    _rotateController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _rotateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(
        0xFF181c27,
      ), // Dark background from your logo
      body: Stack(
        children: [
          // Animated background particles
          ...List.generate(15, (index) => _buildFloatingParticle(index)),

          // Main content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo with animations
                AnimatedBuilder(
                  animation: Listenable.merge([
                    _scaleAnimation,
                    _rotateAnimation,
                  ]),
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _scaleAnimation.value,
                      child: Transform.rotate(
                        angle: _rotateAnimation.value * 0.1,
                        child: Container(
                          width: 200,
                          height: 200,
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF7B68EE).withOpacity(0.3),
                                blurRadius: 30,
                                spreadRadius: 10,
                              ),
                            ],
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Image.asset(
                                'assets/images/splash_image.png',
                                width: 160,
                                height: 160,
                                errorBuilder: (context, error, stackTrace) {
                                  // Fallback if image not found
                                  return _buildFallbackLogo();
                                },
                              ),

                              // Sparkle effects
                              Positioned(
                                top: 20,
                                right: 30,
                                child: _buildSparkle(0),
                              ),
                              Positioned(
                                bottom: 40,
                                left: 20,
                                child: _buildSparkle(1),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 40),

                // App name with animation
                Text(
                      'Magic Ledger',
                      style: const TextStyle(
                        fontSize: 42,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF7B68EE),
                        letterSpacing: -1,
                      ),
                    )
                    .animate()
                    .fadeIn(delay: 800.ms, duration: 800.ms)
                    .slideY(begin: 0.3, end: 0, delay: 800.ms)
                    .scale(begin: const Offset(0.8, 0.8), delay: 800.ms),

                const SizedBox(height: 12),

                // Tagline
                Text(
                      'Track. Save. Achieve.',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: Colors.white.withOpacity(0.7),
                        letterSpacing: 2,
                      ),
                    )
                    .animate()
                    .fadeIn(delay: 1200.ms, duration: 800.ms)
                    .slideY(begin: 0.2, end: 0, delay: 1200.ms),

                const SizedBox(height: 80),

                // Loading indicator
                SizedBox(
                      width: 50,
                      child: LinearProgressIndicator(
                        backgroundColor: Colors.white.withOpacity(0.2),
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Color(0xFFFFC045), // Yellow from your palette
                        ),
                        minHeight: 3,
                      ),
                    )
                    .animate()
                    .fadeIn(delay: 1500.ms)
                    .scaleX(
                      begin: 0,
                      end: 1,
                      duration: 1500.ms,
                      delay: 1500.ms,
                    ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Fallback logo if image not found
  Widget _buildFallbackLogo() {
    return Container(
      width: 160,
      height: 160,
      decoration: BoxDecoration(
        color: const Color(0xFF7B68EE),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: const Color(0xFF2D3142), width: 4),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Book icon
          const Icon(
            Icons.menu_book_rounded,
            size: 80,
            color: Color(0xFF2D3142),
          ),
          // Dollar icon overlay
          Positioned(
            bottom: 30,
            right: 30,
            child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: const Color(0xFFFFC045),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF2D3142), width: 3),
              ),
              child: const Center(
                child: Text(
                  '\$',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF2D3142),
                  ),
                ),
              ),
            ),
          ),
          // Magic wand
          Positioned(
            top: 20,
            left: 30,
            child: Transform.rotate(
              angle: -0.5,
              child: Container(
                width: 40,
                height: 8,
                decoration: BoxDecoration(
                  color: const Color(0xFF2D3142),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Sparkle animation widgets
  Widget _buildSparkle(int index) {
    return Icon(Icons.star, size: 24, color: const Color(0xFFFFC045))
        .animate(onPlay: (controller) => controller.repeat())
        .scale(
          begin: const Offset(0.5, 0.5),
          end: const Offset(1, 1),
          duration: GetNumUtils(1).seconds,
          delay: (index * 500).ms,
        )
        .fadeIn(duration: 500.ms, delay: (index * 500).ms)
        .fadeOut(begin: 1, delay: GetNumUtils(1).seconds)
        .rotate(begin: 0, end: 1, duration: GetNumUtils(2).seconds);
  }

  // Floating particles in background
  Widget _buildFloatingParticle(int index) {
    final random = index * 0.1;
    final size = 4.0 + (index % 3) * 2;
    final duration = 3000 + (index * 200);

    return Positioned(
      left: (index * 67) % MediaQuery.of(context).size.width,
      top: (index * 97) % MediaQuery.of(context).size.height,
      child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color:
                  [
                    const Color(0xFF7B68EE).withOpacity(0.3),
                    const Color(0xFFFFC045).withOpacity(0.3),
                    Colors.white.withOpacity(0.2),
                  ][index % 3],
              shape: BoxShape.circle,
            ),
          )
          .animate(onPlay: (controller) => controller.repeat())
          .moveY(
            begin: 0,
            end: -30,
            duration: duration.ms,
            curve: Curves.easeInOut,
          )
          .fadeIn()
          .fadeOut(begin: 1, delay: (duration - 500).ms),
    );
  }
}
