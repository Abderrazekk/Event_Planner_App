// element_details.dart
import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:ui';
import 'package:video_player/video_player.dart';
import 'package:wedding/screens/client/chat_client.dart';
import 'package:wedding/services/api_service.dart';
import 'package:wedding/screens/client/schedule_client.dart';

class ElementDetailsClientScreen extends StatefulWidget {
  final String elementId;
  final String elementName;
  final File? elementImage;
  final String elementAddress;
  final String elementPrice;
  final String elementDescription;
  final String elementImageUrl;

  const ElementDetailsClientScreen({
    Key? key,
    required this.elementId,
    required this.elementName,
    this.elementImage,
    required this.elementAddress,
    required this.elementPrice,
    required this.elementDescription,
    required this.elementImageUrl,
  }) : super(key: key);

  @override
  State<ElementDetailsClientScreen> createState() =>
      _ElementDetailsClientScreenState();
}

class _ElementDetailsClientScreenState extends State<ElementDetailsClientScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> _tabs = ['Photos', 'Videos'];
  int _currentIndex = 0;

  // Media management variables
  List<dynamic> _mediaList = [];
  bool _isLoadingMedia = false;

  // Fullscreen media variables
  // ignore: unused_field
  File? _fullScreenMedia;
  bool _isFullScreenVideo = false;
  VideoPlayerController? _videoController;
  bool _showVideoControls = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: _tabs.length,
      vsync: this,
      initialIndex: 0,
    );
    _tabController.addListener(_handleTabChange);
    _fetchMedia();
  }

  void _handleTabChange() {
    setState(() {
      _currentIndex = _tabController.index;
    });
  }

  // Fetch media from backend
  Future<void> _fetchMedia() async {
    setState(() {
      _isLoadingMedia = true;
    });

    try {
      final media = await ApiService.getElementMedia(widget.elementId);
      setState(() {
        _mediaList = media;
        _isLoadingMedia = false;
      });
    } catch (e) {
      print('Error fetching media: $e');
      setState(() {
        _isLoadingMedia = false;
      });
    }
  }

  // Open media in fullscreen
  void _openMediaFullScreen(String mediaUrl, bool isVideo) {
    if (isVideo) {
      _videoController?.dispose();
      _videoController = VideoPlayerController.network(mediaUrl)
        ..initialize().then((_) {
          setState(() {
            _isFullScreenVideo = true;
            _videoController!.play();
          });
        });
    } else {
      // For images, we'll show a dialog with the image
      showDialog(
        context: context,
        builder:
            (context) => Dialog(
              child: InteractiveViewer(
                panEnabled: true,
                minScale: 0.1,
                maxScale: 4.0,
                child: Image.network(mediaUrl),
              ),
            ),
      );
    }
  }

  // Close fullscreen media
  void _closeFullScreenMedia() {
    if (_isFullScreenVideo && _videoController != null) {
      _videoController!.pause();
      _videoController!.dispose();
      _videoController = null;
    }

    setState(() {
      _fullScreenMedia = null;
      _isFullScreenVideo = false;
    });
  }

  void _toggleVideoPlayback() {
    setState(() {
      if (_videoController!.value.isPlaying) {
        _videoController!.pause();
      } else {
        _videoController!.play();
      }
    });
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Container(),
      ),
      body: Stack(
        children: [
          // Main content
          CustomScrollView(
            slivers: [
              // Hero image section
              SliverToBoxAdapter(
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(12),
                        bottomRight: Radius.circular(12),
                      ),
                      child: SizedBox(
                        height: 280,
                        width: double.infinity,
                        child: ShaderMask(
                          shaderCallback: (rect) {
                            return LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withOpacity(0.7),
                              ],
                              stops: const [0.6, 1.0],
                            ).createShader(rect);
                          },
                          blendMode: BlendMode.darken,
                          child:
                              // FIXED: Properly handle both local file and network image
                              widget.elementImage != null
                                  ? Image.file(
                                    widget.elementImage!,
                                    fit: BoxFit.cover,
                                  )
                                  : widget.elementImageUrl.isNotEmpty
                                  ? Image.network(
                                    widget.elementImageUrl,
                                    fit: BoxFit.cover,
                                    loadingBuilder: (context, child, progress) {
                                      return progress == null
                                          ? child
                                          : const Center(
                                            child: CircularProgressIndicator(),
                                          );
                                    },
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        color: Colors.grey.shade800,
                                        child: const Center(
                                          child: Icon(
                                            Icons.broken_image,
                                            size: 50,
                                          ),
                                        ),
                                      );
                                    },
                                  )
                                  : Container(
                                    color: Colors.grey.shade800,
                                    child: const Center(
                                      child: Icon(Icons.image, size: 50),
                                    ),
                                  ),
                        ),
                      ),
                    ),
                    SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.1),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 8,
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: BackdropFilter(
                                  filter: ImageFilter.blur(
                                    sigmaX: 10,
                                    sigmaY: 10,
                                  ),
                                  child: IconButton(
                                    icon: const Icon(
                                      Icons.arrow_back,
                                      color: Colors.white,
                                    ),
                                    onPressed: () => Navigator.pop(context),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 24,
                      left: 0,
                      right: 0,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              widget.elementName,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.5,
                                shadows: [
                                  Shadow(
                                    offset: Offset(0, 1),
                                    blurRadius: 3,
                                    color: Colors.black54,
                                  ),
                                ],
                              ),
                            ),
                            Row(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: BackdropFilter(
                                      filter: ImageFilter.blur(
                                        sigmaX: 5,
                                        sigmaY: 5,
                                      ),
                                      child: IconButton(
                                        icon: const Icon(
                                          Icons.schedule,
                                          color: Colors.white,
                                        ),
                                        onPressed:
                                            () => Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder:
                                                    (context) =>
                                                        ScheduleClientScreen(
                                                          elementId:
                                                              widget.elementId,
                                                        ),
                                              ),
                                            ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: BackdropFilter(
                                      filter: ImageFilter.blur(
                                        sigmaX: 5,
                                        sigmaY: 5,
                                      ),
                                      child: IconButton(
                                        icon: const Icon(
                                          Icons.message,
                                          color: Colors.white,
                                        ),
                                        onPressed:
                                            () => Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder:
                                                    (context) =>
                                                        const ChatClientScreen(),
                                              ),
                                            ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Details content section
              SliverPadding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20.0,
                  vertical: 16.0,
                ),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Description section
                          Text(
                            'Description',
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: Colors.black87,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            widget.elementDescription,
                            style: const TextStyle(
                              fontSize: 16,
                              height: 1.6,
                              color: Colors.black54,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          const SizedBox(height: 24),
                          const Divider(color: Colors.black12, thickness: 1),
                          const SizedBox(height: 24),

                          // Address section
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(
                                Icons.location_on_outlined,
                                color: Colors.black87,
                                size: 22,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  widget.elementAddress,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    color: Colors.black87,
                                    height: 1.4,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),

                          // Price section
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.05),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.monetization_on_outlined,
                                  color: Colors.black,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                ' ${widget.elementPrice} TND',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ]),
                ),
              ),

              // Tab bar section
              SliverPersistentHeader(
                pinned: true,
                delegate: _TabBarDelegate(
                  tabController: _tabController,
                  tabs: _tabs,
                  currentIndex: _currentIndex,
                ),
              ),

              // Tab content section
              SliverToBoxAdapter(
                child: SizedBox(
                  height: MediaQuery.of(context).size.height * 0.6,
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      // Photos content
                      _buildMediaTab(
                        icon: Icons.photo_library,
                        color: Colors.blue,
                        isPhotoTab: true,
                      ),
                      // Videos content
                      _buildMediaTab(
                        icon: Icons.video_library,
                        color: Colors.red,
                        isPhotoTab: false,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Fullscreen media overlay with fixed close functionality
          if (_isFullScreenVideo && _videoController != null)
            Container(
              color: Colors.black87,
              child: Stack(
                children: [
                  // Media content
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _showVideoControls = !_showVideoControls;
                      });
                    },
                    child: Center(
                      child:
                          (_videoController != null &&
                                  _videoController!.value.isInitialized)
                              ? AspectRatio(
                                aspectRatio:
                                    _videoController!.value.aspectRatio,
                                child: VideoPlayer(_videoController!),
                              )
                              : const Center(
                                child: CircularProgressIndicator(),
                              ),
                    ),
                  ),

                  // Fixed close button
                  Positioned(
                    top: MediaQuery.of(context).padding.top + 20,
                    right: 20,
                    child: IconButton(
                      icon: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 32,
                      ),
                      onPressed: _closeFullScreenMedia,
                    ),
                  ),

                  // Video controls
                  if (_showVideoControls)
                    Positioned(
                      bottom: 30,
                      left: 0,
                      right: 0,
                      child: VideoProgressIndicator(
                        _videoController!,
                        allowScrubbing: true,
                        colors: const VideoProgressColors(
                          playedColor: Colors.red,
                          bufferedColor: Colors.grey,
                          backgroundColor: Colors.white24,
                        ),
                      ),
                    ),

                  if (_showVideoControls)
                    Positioned(
                      bottom: 60,
                      left: 0,
                      right: 0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.replay_10,
                              color: Colors.white,
                              size: 30,
                            ),
                            onPressed: () {
                              _videoController!.seekTo(
                                _videoController!.value.position -
                                    const Duration(seconds: 10),
                              );
                            },
                          ),
                          IconButton(
                            icon: Icon(
                              _videoController!.value.isPlaying
                                  ? Icons.pause
                                  : Icons.play_arrow,
                              color: Colors.white,
                              size: 36,
                            ),
                            onPressed: _toggleVideoPlayback,
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.forward_10,
                              color: Colors.white,
                              size: 30,
                            ),
                            onPressed: () {
                              _videoController!.seekTo(
                                _videoController!.value.position +
                                    const Duration(seconds: 10),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMediaTab({
    required IconData icon,
    required Color color,
    required bool isPhotoTab,
  }) {
    // Filter media by type
    final filteredMedia =
        _mediaList
            .where((media) => media['type'] == (isPhotoTab ? 'photo' : 'video'))
            .toList();

    return Container(
      key: ValueKey<String>(isPhotoTab ? 'Photos' : 'Videos'),
      padding: const EdgeInsets.only(
        top: 15,
        left: 15,
        right: 15,
        bottom: 20,
      ), // Reduced top padding
      child: Column(
        children: [
          // Loading indicator
          if (_isLoadingMedia) const Center(child: CircularProgressIndicator()),

          // Media grid view
          Expanded(
            child:
                filteredMedia.isEmpty && !_isLoadingMedia
                    ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: color.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              icon,
                              size: 50,
                              color: color.withOpacity(0.7),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'No ${isPhotoTab ? 'photos' : 'videos'} available yet',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                    )
                    : GridView.builder(
                      padding: EdgeInsets.zero, // Remove any default padding
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 15,
                            childAspectRatio: 1,
                          ),
                      itemCount: filteredMedia.length,
                      itemBuilder: (context, index) {
                        final media = filteredMedia[index];
                        final isVideo = media['type'] == 'video';
                        final mediaUrl =
                            '${ApiService.baseUrl}${media['path']}';

                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: GestureDetector(
                              onTap:
                                  () => _openMediaFullScreen(mediaUrl, isVideo),
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  // Media content - using NetworkImage for backend-stored media
                                  Container(
                                    decoration:
                                        !isVideo
                                            ? BoxDecoration(
                                              image: DecorationImage(
                                                image: NetworkImage(mediaUrl),
                                                fit: BoxFit.cover,
                                              ),
                                            )
                                            : null,
                                    color:
                                        isVideo
                                            ? Colors.black.withOpacity(0.2)
                                            : null,
                                    child:
                                        isVideo
                                            ? Center(
                                              child: Container(
                                                padding: const EdgeInsets.all(
                                                  12,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: Colors.white
                                                      .withOpacity(0.25),
                                                  shape: BoxShape.circle,
                                                ),
                                                child: const Icon(
                                                  Icons.play_arrow,
                                                  size: 40,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            )
                                            : null,
                                  ),

                                  // Overlay gradient
                                  Positioned(
                                    bottom: 0,
                                    left: 0,
                                    right: 0,
                                    child: Container(
                                      height: 30,
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                          colors: [
                                            Colors.transparent,
                                            Colors.black.withOpacity(0.7),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
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

class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabController tabController;
  final List<String> tabs;
  final int currentIndex;

  _TabBarDelegate({
    required this.tabController,
    required this.tabs,
    required this.currentIndex,
  });

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        children: List.generate(
          tabs.length,
          (index) => Expanded(
            child: GestureDetector(
              onTap: () => tabController.animateTo(index),
              child: Container(
                height: 46,
                margin: const EdgeInsets.symmetric(horizontal: 5),
                decoration: BoxDecoration(
                  color:
                      currentIndex == index
                          ? Theme.of(
                            context,
                          ).colorScheme.onBackground.withOpacity(0.1)
                          : Colors.transparent,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color:
                        currentIndex == index
                            ? Theme.of(context).colorScheme.onBackground
                            : Colors.transparent,
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        index == 0 ? Icons.photo_library : Icons.video_library,
                        color:
                            currentIndex == index
                                ? Theme.of(context).colorScheme.onBackground
                                : Colors.grey,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        tabs[index],
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color:
                              currentIndex == index
                                  ? Theme.of(context).colorScheme.onBackground
                                  : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  double get maxExtent => 62;

  @override
  double get minExtent => 62;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return true;
  }
}
