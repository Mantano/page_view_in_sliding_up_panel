import 'dart:math';

import 'package:flutter_fimber/flutter_fimber.dart';
import 'package:flutter/material.dart';
import 'package:sliding_up_panel2/sliding_up_panel2.dart';

void main() {
  Fimber.plantTree(DebugTree());
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PanelController _panelController = PanelController();
  bool _isPageViewScrolling = false;
  bool _isPanelScrolling = false;
  late PageController _pageController;
  int _currentPage = 0;
  double _usableScreenHeight = 0;
  double _opacity = 1.0;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Fimber.d("Build HomeScreen, currentPage: $_currentPage");
    _pageController = PageController(initialPage: _currentPage);

    _usableScreenHeight = MediaQuery.of(context).size.height -
        MediaQuery.of(context).padding.top -
        MediaQuery.of(context).padding.bottom;

    return Scaffold(
      appBar: AppBar(
        title: Text('PageView in SlidingUpPanel'),
      ),
      body: NotificationListener<ScrollNotification>(
        onNotification: (ScrollNotification notification) {
          if (notification is ScrollStartNotification) {
            if (notification.metrics.axis == Axis.horizontal) {
              setState(() {
                _isPageViewScrolling = true;
              });
            } else if (notification.metrics.axis == Axis.vertical) {
              setState(() {
                _isPanelScrolling = true;
              });
            }
          } else if (notification is ScrollEndNotification) {
            Fimber.d(
                "ScrollEndNotification in sliding panel, Page Changed: ${_pageController.page!.toInt()}");
            setState(() {
              _isPageViewScrolling = false;
              _isPanelScrolling = false;
            });
          }
          return false;
        },
        child: SlidingUpPanel(
          controller: _panelController,
          maxHeight: _usableScreenHeight,
          minHeight: 100,
          onPanelSlide: _onPanelSlide,
          parallaxEnabled: true,
          parallaxOffset: .5,
          isDraggable: !_isPageViewScrolling,
          body: Container(
            color: Colors.cyan,
            child: const Center(
              child: Text(
                'Body Content',
                style: TextStyle(fontSize: 24, color: Colors.white),
              ),
            ),
          ),
          panelBuilder: () => _buildPanel(),
        ),
      ),
    );
  }

  Widget _buildPanel() {
    Fimber.d("Build panel, _currentPage: $_currentPage");
    // SchedulerBinding.instance.addPostFrameCallback((_) {
    //   if (_currentPage != _pageController.page!.toInt()) {
    //     _pageController.jumpToPage(_currentPage);
    //   }
    // });
    return NotificationListener<ScrollNotification>(
      onNotification: (ScrollNotification notification) {
        if (notification is ScrollStartNotification) {
          if (notification.metrics.axis == Axis.horizontal) {
            setState(() {
              _isPageViewScrolling = true;
            });
          } else if (notification.metrics.axis == Axis.vertical) {
            setState(() {
              _isPanelScrolling = true;
            });
          }
        } else if (notification is ScrollEndNotification) {
          Fimber.d(
              "ScrollEndNotification in PageView, Page Changed: ${_pageController.page!.toInt()}");
          setState(() {
            _currentPage = _pageController.page!.toInt();
            _isPageViewScrolling = false;
            _isPanelScrolling = false;
          });
        }
        return false;
      },
      // Now, in the panel of the slidinguppanel, I'd like to stack a list containing 100 items (for example the top 100 songs from the 50s). This list should be below the PageView. The PageVew should have as height 50% of the display height. The sliding up panel should take all the display when opened.
      child: Stack(
        children: [
          Container(
            margin: EdgeInsets.all(0),
            child: ListView.builder(
              itemCount: 100,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text('Song $index'),
                );
              },
            ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: Opacity(
              opacity: _opacity,
              child: Container(
                height: _usableScreenHeight / 8,
                child: PageView(
                  controller: _pageController,
                  physics: _isPanelScrolling
                      ? NeverScrollableScrollPhysics()
                      : PageScrollPhysics(),
                  onPageChanged: (int index) {
                    Fimber.d("Page Changed: $index");
                    _currentPage = _pageController.page!.toInt();
                  },
                  children: [
                    Container(
                      color: Colors.red,
                      child: const Center(
                        child: Text(
                          'Page 1',
                          style: TextStyle(fontSize: 24, color: Colors.white),
                        ),
                      ),
                    ),
                    Container(
                      color: Colors.blue,
                      child: const Center(
                        child: Text(
                          'Page 2',
                          style: TextStyle(fontSize: 24, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _onPanelSlide(double position) {
    setState(() {
      // Calculate new opacity value
      _opacity = max(0.0, 1.0 - 2 * position);
    });
  }
}
