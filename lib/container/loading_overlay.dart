import 'package:flutter/material.dart';

class LoadingOverlay extends StatelessWidget {
  /// Optionnellement, un texte de chargement.
  final String? loadingText;

  const LoadingOverlay({super.key, this.loadingText});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Fond semi-transparent qui bloque les interactions.
        const ModalBarrier(
          dismissible: false,
          color: Colors.black54,
        ),
        // Card centrée contenant l'indicateur de chargement.
        Center(
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 8,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: 150,
                height: 150,
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircularProgressIndicator(),
                      if (loadingText != null) ...[
                        const SizedBox(height: 16),
                        Text(
                          loadingText!,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class LoadingOverlayAnimated extends StatefulWidget {
  final String? loadingText;

  /// Permet de contrôler la visibilité de l'overlay.
  final bool isVisible;

  const LoadingOverlayAnimated({
    super.key,
    this.loadingText,
    this.isVisible = true,
  });

  @override
  State<LoadingOverlayAnimated> createState() => _LoadingOverlayAnimatedState();
}

class _LoadingOverlayAnimatedState extends State<LoadingOverlayAnimated>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    // Durée de l'animation réglée à 300 millisecondes.
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);

    // Lance l'animation selon l'état initial.
    if (widget.isVisible) {
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(covariant LoadingOverlayAnimated oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Démarrer ou inverser l'animation en fonction de la visibilité.
    if (widget.isVisible != oldWidget.isVisible) {
      if (widget.isVisible) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _animation,
      child: LoadingOverlay(loadingText: widget.loadingText),
    );
  }
}
