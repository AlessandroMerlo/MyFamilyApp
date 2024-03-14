import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:my_family_app/constants/app_constants.dart';
import 'package:my_family_app/error/scanner_error_widget.dart';
import 'package:my_family_app/screens/product/products.dart';
import 'package:my_family_app/widgets/main_app_bar.dart';
import 'package:my_family_app/widgets/main_drawer.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen>
    with SingleTickerProviderStateMixin {
  BarcodeCapture? barcode;

  final TextEditingController _barcodeController = TextEditingController();

  final MobileScannerController controller = MobileScannerController(
    torchEnabled: false,
  );

  bool isStarted = true;

  void _startOrStop() {
    try {
      if (isStarted) {
        controller.stop();
      } else {
        controller.start();
      }
      setState(() {
        isStarted = !isStarted;
      });
    } on Exception catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Something went wrong! $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      appBar: const MainAppBar(
        mainTitle: appTitle,
        backgroundColor: AppBarColors.scanner,
      ),
      drawer: MainDrawer(
        onNavigatorPush: () => controller.stop(),
      ),
      backgroundColor: Colors.black,
      body: Builder(
        builder: (context) {
          return Stack(
            children: [
              MobileScanner(
                controller: controller,
                errorBuilder: (context, error, child) {
                  return ScannerErrorWidget(error: error);
                },
                fit: BoxFit.cover,
                onDetect: (barcode) {
                  setState(() {
                    this.barcode = barcode;
                  });
                  _barcodeController.text =
                      this.barcode!.barcodes.first.displayValue!;
                },
              ),
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _barcodeController,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        keyboardType:
                            const TextInputType.numberWithOptions(signed: true),
                        textAlign: TextAlign.center,
                        onSubmitted: (value) async {
                          await submitBarcode();
                        },
                        decoration: const InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          label: Text(
                            'BARCODE',
                            textAlign: TextAlign.center,
                          ),
                          border: OutlineInputBorder(
                            borderSide: BorderSide.none,
                          ),
                          floatingLabelBehavior: FloatingLabelBehavior.never,
                        ),
                      ),
                    ),
                    Container(
                      width: 80,
                      height: 72,
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(4)),
                        color: Colors.black,
                      ),
                      child: IconButton(
                          onPressed: () async {
                            await submitBarcode();
                          },
                          icon: const Icon(
                            Icons.double_arrow_rounded,
                            color: Colors.white,
                            size: 52,
                          )),
                    )
                  ],
                ),
              ),
              Positioned(
                bottom: 10,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ValueListenableBuilder(
                      valueListenable: controller.hasTorchState,
                      builder: (context, state, child) {
                        return DecoratedBox(
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.black54,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(40),
                              child: ValueListenableBuilder<TorchState>(
                                valueListenable: controller.torchState,
                                builder: (context, state, child) {
                                  switch (state) {
                                    case TorchState.off:
                                      return const Icon(
                                        Icons.flash_off,
                                        color: Colors.grey,
                                        size: 32,
                                      );
                                    case TorchState.on:
                                      return const Icon(
                                        Icons.flash_on,
                                        color: Colors.yellow,
                                        size: 32,
                                      );
                                  }
                                },
                              ),
                              onTap: () async {
                                if (controller.cameraFacingState.value ==
                                    CameraFacing.front) {
                                  return;
                                }
                                await controller.toggleTorch();
                              },
                            ),
                          ),
                        );
                      },
                    ),
                    DecoratedBox(
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.black54,
                      ),
                      child: IconButton(
                        color: Colors.white,
                        icon: ValueListenableBuilder<CameraFacing>(
                          valueListenable: controller.cameraFacingState,
                          builder: (context, state, child) {
                            switch (state) {
                              case CameraFacing.front:
                                return const Icon(Icons.camera_front);
                              case CameraFacing.back:
                                return const Icon(Icons.camera_rear);
                            }
                          },
                        ),
                        iconSize: 32.0,
                        onPressed: () {
                          controller.switchCamera();
                          if (controller.cameraFacingState.value ==
                                  CameraFacing.front &&
                              controller.torchState.value == TorchState.on) {
                            controller.toggleTorch();
                          }
                        },
                      ),
                    ),
                    DecoratedBox(
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.black54,
                      ),
                      child: IconButton(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        color: Colors.white,
                        icon: const Icon(Icons.camera_outlined),
                        iconSize: 32.0,
                        onPressed: () async {
                          _startOrStop();
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    controller.stop();
    controller.dispose();

    super.dispose();
  }

  Future<void> submitBarcode() async {
    FocusManager.instance.primaryFocus?.unfocus();
    if (_barcodeController.text == '') {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Warning'),
          content: const Text('Inserisci o scannerizza un barcode!!!'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Ok, capito'),
            ),
          ],
        ),
      );
    } else {
      _startOrStop();

      await Navigator.of(context).push(
        MaterialPageRoute(
            builder: (context) =>
                ProductScreen(barcode: _barcodeController.value.text)),
      );
    }
  }
}

class ScannerOverlay extends CustomPainter {
  ScannerOverlay(this.scanWindow);

  final Rect scanWindow;

  @override
  void paint(Canvas canvas, Size size) {
    final backgroundPath = Path()..addRect(Rect.largest);
    final cutoutPath = Path()..addRect(scanWindow);

    final backgroundPaint = Paint()
      ..color = Colors.black.withOpacity(0.5)
      ..style = PaintingStyle.fill
      ..blendMode = BlendMode.dstOut;

    final backgroundWithCutout = Path.combine(
      PathOperation.difference,
      backgroundPath,
      cutoutPath,
    );
    canvas.drawPath(backgroundWithCutout, backgroundPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

class BarcodeOverlay extends CustomPainter {
  BarcodeOverlay({
    required this.barcode,
    required this.arguments,
    required this.boxFit,
    required this.capture,
  });

  final BarcodeCapture capture;
  final Barcode barcode;
  final MobileScannerArguments arguments;
  final BoxFit boxFit;

  @override
  void paint(Canvas canvas, Size size) {
    if (barcode.corners.isEmpty) {
      return;
    }

    final adjustedSize = applyBoxFit(boxFit, arguments.size, size);

    double verticalPadding = size.height - adjustedSize.destination.height;
    double horizontalPadding = size.width - adjustedSize.destination.width;
    if (verticalPadding > 0) {
      verticalPadding = verticalPadding / 2;
    } else {
      verticalPadding = 0;
    }

    if (horizontalPadding > 0) {
      horizontalPadding = horizontalPadding / 2;
    } else {
      horizontalPadding = 0;
    }

    final double ratioWidth;
    final double ratioHeight;

    if (!kIsWeb && Platform.isIOS) {
      ratioWidth = capture.size.width / adjustedSize.destination.width;
      ratioHeight = capture.size.height / adjustedSize.destination.height;
    } else {
      ratioWidth = arguments.size.width / adjustedSize.destination.width;
      ratioHeight = arguments.size.height / adjustedSize.destination.height;
    }

    final List<Offset> adjustedOffset = [];
    for (final offset in barcode.corners) {
      adjustedOffset.add(
        Offset(
          offset.dx / ratioWidth + horizontalPadding,
          offset.dy / ratioHeight + verticalPadding,
        ),
      );
    }
    final cutoutPath = Path()..addPolygon(adjustedOffset, true);

    final backgroundPaint = Paint()
      ..color = Colors.red.withOpacity(0.3)
      ..style = PaintingStyle.fill
      ..blendMode = BlendMode.dstOut;

    canvas.drawPath(cutoutPath, backgroundPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
