// [Presentation Layer] — 지도/기억 목록 화면 렌더링 담당
import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import '../../application/view_models/auth_view_model.dart';
import '../../application/view_models/capsule_view_model.dart';
import '../../domain/entities/capsule.dart';
import '../../domain/services/location_service.dart';
import '../theme/app_theme.dart';
import 'capsule_create_screen.dart';
import 'capsule_detail_screen.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final Completer<GoogleMapController> _mapController = Completer();
  final LocationService _locationService = LocationService();

  Position? _currentPosition;
  Set<Marker> _markers = {};
  BitmapDescriptor? _customMarker;

  static const _defaultPosition = LatLng(37.5665, 126.9780);

  @override
  void initState() {
    super.initState();
    _createCustomMarker();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userId = context.read<AuthViewModel>().user?.uid;
      if (userId != null) {
        context.read<CapsuleViewModel>().startWatching(userId);
      }
      _initLocation();
    });
  }

  Future<void> _createCustomMarker() async {
    try {
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);
      const size = 96.0;
      const iconSize = 52.0;

      final textPainter = TextPainter(
        text: TextSpan(
          text: String.fromCharCode(Icons.bookmark.codePoint),
          style: TextStyle(
            fontSize: iconSize,
            fontFamily: Icons.bookmark.fontFamily,
            color: const Color(0xFFB87A50),
          ),
        ),
        textDirection: ui.TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(
          (size - textPainter.width) / 2,
          (size - textPainter.height) / 2,
        ),
      );

      final picture = recorder.endRecording();
      final image = await picture.toImage(size.toInt(), size.toInt());
      final bytes = await image.toByteData(format: ui.ImageByteFormat.png);

      if (bytes != null && mounted) {
        setState(() {
          _customMarker =
              BitmapDescriptor.fromBytes(bytes.buffer.asUint8List());
        });
      }
    } catch (_) {
      setState(() {
        _customMarker = BitmapDescriptor.defaultMarkerWithHue(30);
      });
    }
  }

  Future<void> _initLocation() async {
    try {
      final position = await _locationService.getCurrentPosition();
      setState(() => _currentPosition = position);
      final controller = await _mapController.future;
      await controller.animateCamera(
        CameraUpdate.newLatLngZoom(
          LatLng(position.latitude, position.longitude),
          15,
        ),
      );
    } catch (_) {}
  }

  void _updateMarkers(List<Capsule> capsules, BuildContext context) {
    final marker = _customMarker ?? BitmapDescriptor.defaultMarkerWithHue(30);
    setState(() {
      _markers = capsules.map((c) {
        return Marker(
          markerId: MarkerId(c.id),
          position: LatLng(c.latitude, c.longitude),
          icon: marker,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => CapsuleDetailScreen(capsule: c),
            ),
          ),
          infoWindow: InfoWindow(
            title:
                c.memo.length > 20 ? '${c.memo.substring(0, 20)}...' : c.memo,
            snippet: DateFormat('yyyy.MM.dd').format(c.createdAt),
          ),
        );
      }).toSet();
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthViewModel>();
    final capsuleVm = context.watch<CapsuleViewModel>();
    final email = auth.user?.email ?? '';

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateMarkers(capsuleVm.capsules, context);
    });

    return Scaffold(
      backgroundColor: AppTheme.warmCream,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: AppTheme.warmCream,
            floating: true,
            snap: true,
            elevation: 0,
            scrolledUnderElevation: 0,
            title: Text('장소 기억 아카이브',
                style: GoogleFonts.gaegu(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textDark)),
            actions: [
              IconButton(
                icon: const Icon(Icons.logout_rounded, size: 20),
                color: AppTheme.textLight,
                onPressed: () async {
                  context.read<CapsuleViewModel>().stopWatching();
                  await auth.signOut();
                },
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    DateFormat('yyyy년 M월 d일 EEEE', 'ko').format(DateTime.now()),
                    style: GoogleFonts.gaegu(
                        fontSize: 14, color: AppTheme.textLight),
                  ),
                  const SizedBox(height: 4),
                  Text('오늘도 어디선가\n기억을 남기고 있나요 ✦',
                      style: GoogleFonts.gaegu(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textDark,
                          height: 1.4)),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: SizedBox(
                  height: 240,
                  child: GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: _currentPosition != null
                          ? LatLng(_currentPosition!.latitude,
                              _currentPosition!.longitude)
                          : _defaultPosition,
                      zoom: 15,
                    ),
                    onMapCreated: (c) => _mapController.complete(c),
                    markers: _markers,
                    myLocationEnabled: true,
                    myLocationButtonEnabled: false,
                    zoomControlsEnabled: false,
                    mapToolbarEnabled: false,
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
              child: Row(
                children: [
                  Text('내 기억들',
                      style: GoogleFonts.gaegu(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textDark)),
                  const SizedBox(width: 8),
                  if (!capsuleVm.isLoading)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryLight,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text('${capsuleVm.capsules.length}개',
                          style: GoogleFonts.gaegu(
                              fontSize: 13,
                              color: AppTheme.primary,
                              fontWeight: FontWeight.w600)),
                    ),
                  const Spacer(),
                  Text(email,
                      style: GoogleFonts.notoSans(
                          fontSize: 11, color: AppTheme.textLight)),
                ],
              ),
            ),
          ),
          _buildCapsuleList(capsuleVm),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const CapsuleCreateScreen()),
        ),
        backgroundColor: AppTheme.primary,
        icon: const Icon(Icons.add_location_alt_outlined),
        label: Text('기억 남기기',
            style: GoogleFonts.gaegu(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Colors.white)),
      ),
    );
  }

  Widget _buildCapsuleList(CapsuleViewModel capsuleVm) {
    if (capsuleVm.isLoading) {
      return const SliverFillRemaining(
        child:
            Center(child: CircularProgressIndicator(color: AppTheme.primary)),
      );
    }

    if (capsuleVm.capsules.isEmpty) {
      return SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('📝', style: TextStyle(fontSize: 40)),
              const SizedBox(height: 12),
              Text('아직 남긴 기억이 없어요',
                  style: GoogleFonts.gaegu(
                      fontSize: 16, color: AppTheme.textMedium)),
              const SizedBox(height: 4),
              Text('아래 버튼을 눌러 첫 기억을 남겨보세요',
                  style: GoogleFonts.notoSans(
                      fontSize: 12, color: AppTheme.textLight)),
            ],
          ),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      sliver: SliverList.separated(
        itemCount: capsuleVm.capsules.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) =>
            _CapsuleCard(capsule: capsuleVm.capsules[index]),
      ),
    );
  }
}

class _CapsuleCard extends StatelessWidget {
  final Capsule capsule;
  const _CapsuleCard({required this.capsule});

  @override
  Widget build(BuildContext context) {
    final day = DateFormat('d').format(capsule.createdAt);
    final month = DateFormat('MMM', 'ko').format(capsule.createdAt);
    final time = DateFormat('HH:mm').format(capsule.createdAt);

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => CapsuleDetailScreen(capsule: capsule)),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.warmBorder),
        ),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                width: 56,
                decoration: const BoxDecoration(
                  color: AppTheme.primaryLight,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(15),
                    bottomLeft: Radius.circular(15),
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(day,
                        style: GoogleFonts.gaegu(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.primary)),
                    Text(month,
                        style: GoogleFonts.gaegu(
                            fontSize: 12, color: AppTheme.textMedium)),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.location_on_outlined,
                              size: 12, color: AppTheme.textLight),
                          const SizedBox(width: 3),
                          Text(
                            '${capsule.latitude.toStringAsFixed(3)}, '
                            '${capsule.longitude.toStringAsFixed(3)}',
                            style: GoogleFonts.notoSans(
                                fontSize: 10, color: AppTheme.textLight),
                          ),
                          const Spacer(),
                          Text(time,
                              style: GoogleFonts.notoSans(
                                  fontSize: 10, color: AppTheme.textLight)),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: capsule.isPublic
                                  ? AppTheme.primaryLight
                                  : AppTheme.warmBeige,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              capsule.isPublic ? '공개' : '비공개',
                              style: GoogleFonts.notoSans(
                                fontSize: 9,
                                color: capsule.isPublic
                                    ? AppTheme.primary
                                    : AppTheme.textLight,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(capsule.memo,
                          style: GoogleFonts.gaegu(
                              fontSize: 15,
                              color: AppTheme.textDark,
                              height: 1.5),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text('자세히 보기 →',
                              style: GoogleFonts.notoSans(
                                  fontSize: 10, color: AppTheme.primary)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
