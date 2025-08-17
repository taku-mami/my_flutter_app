import 'package:flutter/material.dart';
import 'package:kakao_map_plugin/kakao_map_plugin.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/app_drawer.dart';

class ServicePage extends StatefulWidget {
  const ServicePage({super.key});

  @override
  State<ServicePage> createState() => _ServicePageState();
}

class _ServicePageState extends State<ServicePage> {
  KakaoMapController? _mapController;
  
  final LatLng seomyeonStation = LatLng(35.157759003, 129.059317193); // 서면역 좌표
  final LatLng jeonpoStation = LatLng(35.152854756, 129.065219588); // 전포역 좌표

  Marker? destinationMarker;
  Polyline? routePolyline;
  bool _isMapReady = false;

  void _selectDestination(BuildContext context) {
    // 목적지 선택 로직 구현
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('목적지 선택'),
        content: const Text('목적지를 선택하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // 목적지 선택 처리
              _handleDestinationSelection(context);
            },
            child: const Text('선택'),
          ),
        ],
      ),
    );
  }

  void _createRoutePolyline() async {
    try {
      // 지도가 준비되었는지 확인
      if (!_isMapReady || _mapController == null) {
        print('지도가 아직 준비되지 않았습니다.');
        return;
      }
      
      // 추가 대기 시간 (지도 완전 렌더링 대기)
      await Future.delayed(const Duration(milliseconds: 500)); // 0.5초 대기
      
      // 서면역에서 전포역까지의 경로 좌표 배열
      final List<LatLng> linePath = [
        seomyeonStation, // 서면역
        jeonpoStation,   // 전포역
      ];

      print('경로 좌표 배열 생성 완료: ${linePath.length}개 포인트');
      print('서면역 좌표: ${seomyeonStation.latitude}, ${seomyeonStation.longitude}');
      print('전포역 좌표: ${jeonpoStation.latitude}, ${jeonpoStation.longitude}');

      // Polyline 생성
      final polyline = Polyline(
        polylineId: 'route_to_jeonpo',
        points: linePath,
        strokeColor: const Color(0xFFFFAE00), // 주황색 (#FFAE00)
        strokeOpacity: 0.7, // 불투명도 0.7
        strokeWidth: 5, // 선 두께 5
        strokeStyle: StrokeStyle.solid, // 실선 스타일
        zIndex: 1,
      );
      
      // 지도에 polyline 추가
      await _mapController!.addPolyline(polylines: [polyline]);
      
      // 상태 업데이트
      setState(() {
        routePolyline = polyline;
      });
    } catch (e) {
      print('경로 선 생성 오류: $e');
      print('오류 스택 트레이스: ${StackTrace.current}');
    }
  }

  void _handleDestinationSelection(BuildContext context) async {
    try {
      // 지도가 준비되었는지 확인
      if (!_isMapReady || _mapController == null) {
        print('지도가 아직 준비되지 않았습니다.');
        return;
      }

      // 전포역 마커 생성
      final marker = Marker(
        markerId: 'jeonpoStation',
        latLng: jeonpoStation,
      );

      print('마커 추가 시작...');
      
      // 마커 추가
      await _mapController!.addMarker(markers: [marker]);
      print('마커 추가 완료');
      
      // 경로 선 생성
      _createRoutePolyline();
      
      // 상태 업데이트
      setState(() {
        destinationMarker = marker;
      });

      // 지도 중심을 경로 중간 지점으로 이동하고 줌 레벨 조정
      final centerLat = (seomyeonStation.latitude + jeonpoStation.latitude) / 2;
      final centerLng = (seomyeonStation.longitude + jeonpoStation.longitude) / 2;
      final centerPoint = LatLng(centerLat, centerLng);
      
      _mapController!.setCenter(centerPoint);
      _mapController!.setLevel(4); // 경로를 잘 볼 수 있도록 줌 레벨 조정
      print('지도 중심 이동 및 줌 레벨 조정 완료');
      
      print('전포역 마커 및 경로 생성됨');
    } catch (e) {
      print('마커 생성 오류: $e');
      print('오류 스택 트레이스: ${StackTrace.current}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(66.0), // 50 + 16
        child: Builder(
          builder: (context) => CustomAppBar(
            title: '서비스',
            showMenuButton: true,
            onMenuPressed: () {
              Scaffold.of(context).openDrawer();
            },
          ),
        ),
      ),
      drawer: const AppDrawer(),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1a1a1a),
              Color(0xFF000000),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(0.0),
            child: Column(
              children: [                
                // 카카오 지도
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.grey[800]!,
                        width: 1,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Stack(
                        children: [
                          KakaoMap(
                            onMapCreated: (KakaoMapController controller) async {
                              setState(() {
                                _mapController = controller;
                              });
                              print('카카오 지도가 생성되었습니다.');
                              
                              // 지도 초기화 완료를 기다림
                              await Future.delayed(const Duration(milliseconds: 1000));
                              setState(() {
                                _isMapReady = true;
                              });
                              print('지도 초기화 완료');
                            },
                            center: LatLng(35.157759003, 129.059317193), // 서면역 좌표
                            currentLevel: 5, // 지도의 확대 레벨
                            zoomControl: true, // 확대 축소 버튼 표시

                          ),
                          
                          // 목적지 선택 버튼
                          Positioned(
                            left: 0,
                            right: 0,
                            bottom: MediaQuery.of(context).size.height * 0.05, // 하단에서 5% 위
                            child: Center(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: _isMapReady ? Colors.white : Colors.grey[300],
                                  borderRadius: BorderRadius.circular(8),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(_isMapReady ? 0.2 : 0.1),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Material(
                                  color: Colors.transparent,
                                                                  child: InkWell(
                                  onTap: _isMapReady ? () {
                                    _selectDestination(context);
                                  } : null,
                                    borderRadius: BorderRadius.circular(8),
                                    child: const Padding(
                                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.location_on,
                                            color: Colors.blue,
                                            size: 20,
                                          ),
                                          SizedBox(width: 8),
                                          Text(
                                            '목적지 선택',
                                            style: TextStyle(
                                              color: Colors.black87,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 14,
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
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
