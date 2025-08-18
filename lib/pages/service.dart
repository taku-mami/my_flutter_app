import 'package:flutter/material.dart';
import 'package:kakao_map_plugin/kakao_map_plugin.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/app_drawer.dart';
import 'dart:convert';

class ServicePage extends StatefulWidget {
  const ServicePage({super.key});

  @override
  State<ServicePage> createState() => _ServicePageState();
}

class _ServicePageState extends State<ServicePage> {
  KakaoMapController? _mapController;
  
  final LatLng seomyeonStation = LatLng(35.157759003, 129.059317193); // 서면역 좌표
  final LatLng jeonpoStation = LatLng(35.152854756, 129.065219588); // 전포역 좌표

  Marker? originMarker;
  Marker? destinationMarker;
  Polyline? routePolyline;
  bool _isMapReady = false;

  /// 도보 경로 정보를 반환하는 임시 함수 (하드코딩)
  String getWalkRoute({
    required LatLng origin,
    required LatLng destination,
    List<LatLng>? waypoints,
  }) {
    // 하드코딩된 경로 정보 반환
    final routeData = {
      "trans_id": "01872ad0a5577deeadc7f87ba0ec2936",
      "routes": [
        {
          "result_code": 0,
          "result_message": "성공",
          "summary": {
            "distance": 1257,
            "duration": 1203
          },
          "sections": [
            {
              "distance": 246,
              "duration": 258,
              "roads": [
                {
                  "distance": 22,
                  "duration": 20,
                  "vertexes": [
                    129.059317193, 35.157759003,
                    129.05925709392375, 35.1545045757588
                  ]
                },
                {
                  "distance": 57,
                  "duration": 51,
                  "vertexes": [
                    129.05925709392375, 35.1545045757588,
                    129.06515984956937, 35.15448517079697,
                  ]
                },
                {
                  "distance": 41,
                  "duration": 37,
                  "vertexes": [
                    129.06515984956937, 35.15448517079697,
                    129.065219588, 35.152854756
                  ]
                }
              ]
            }
          ]
        }
      ]
    };
    
    return jsonEncode(routeData);
  }

    /// 안심 도보 경로 정보를 반환하는 임시 함수 (하드코딩)
  String getSafeWalkRoute({
    required LatLng origin,
    required LatLng destination,
    List<LatLng>? waypoints,
  }) {
    // 하드코딩된 경로 정보 반환
    final routeData = {
      "trans_id": "01872ad0a5577deeadc7f87ba0ec2936",
      "routes": [
        {
          "result_code": 0,
          "result_message": "성공",
          "summary": {
            "distance": 1257,
            "duration": 1203
          },
          "sections": [
            {
              "distance": 246,
              "duration": 258,
              "roads": [
                {
                  "distance": 22,
                  "duration": 20,
                  "vertexes": [
                    129.059317193, 35.157759003,
                    129.06512644062067, 35.157720909772266,
                  ]
                },
                {
                  "distance": 41,
                  "duration": 37,
                  "vertexes": [
                    129.06512644062067, 35.157720909772266,
                    129.065219588, 35.152854756
                  ]
                }
              ]
            }
          ]
        }
      ]
    };
    
    return jsonEncode(routeData);
  }

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



  void _handleDestinationSelection(BuildContext context) async {
    try {
      // 지도가 준비되었는지 확인
      if (!_isMapReady || _mapController == null) {
        print('지도가 아직 준비되지 않았습니다.');
        return;
      }

      // 서면역 마커 생성
      final origin_marker = Marker(
        markerId: 'seomyeonStation',
        latLng: seomyeonStation,
      );

      // 전포역 마커 생성
      final destination_marker = Marker(
        markerId: 'jeonpoStation',
        latLng: jeonpoStation,
      );
      
      // 마커 추가
      await _mapController!.addMarker(markers: [origin_marker, destination_marker]);

      
      // getWalkRoute 함수를 사용하여 경로 정보 가져오기
      final routeJson = getWalkRoute(
        origin: seomyeonStation,
        destination: jeonpoStation,
      );
      
      // print('경로 정보 JSON: $routeJson');
      
      // JSON 파싱하여 roads 정보 추출
      final routeData = jsonDecode(routeJson);
      final roads = routeData['routes'][0]['sections'][0]['roads'] as List;
      
      print('추출된 roads 개수: ${roads.length}');
      
      // 모든 polyline을 한 번에 생성
      final List<Polyline> allPolylines = [];
      
      for (int i = 0; i < roads.length; i++) {
        final road = roads[i];
        final vertexes = road['vertexes'] as List;
        
        // vertexes는 [시작점_경도, 시작점_위도, 도착점_경도, 도착점_위도] 순서
        if (vertexes.length >= 4) {
          final startLng = vertexes[0] as double;
          final startLat = vertexes[1] as double;
          final endLng = vertexes[2] as double;
          final endLat = vertexes[3] as double;
          
          print('Road $i: 시작점($startLat, $startLng) → 도착점($endLat, $endLng)');
          
          // Polyline 생성
          final polyline = Polyline(
            polylineId: 'route_segment_$i',
            points: [
              LatLng(startLat, startLng),
              LatLng(endLat, endLng),
            ],
            strokeColor: Colors.blue, // 파란색 계열
            strokeOpacity: 0.7,
            strokeWidth: 5,
            strokeStyle: StrokeStyle.solid,
            zIndex: 1,
          );
          
          allPolylines.add(polyline);
          print('Road $i polyline 생성 완료');
        }
      }
      
      // getSafeWalkRoute 함수를 사용하여 안전 경로 정보 가져오기
      final safeRouteJson = getSafeWalkRoute(
        origin: seomyeonStation,
        destination: jeonpoStation,
      );
      
      // JSON 파싱하여 안전 경로의 roads 정보 추출
      final safeRouteData = jsonDecode(safeRouteJson);
      final safeRoads = safeRouteData['routes'][0]['sections'][0]['roads'] as List;
      
      print('추출된 안전 경로 roads 개수: ${safeRoads.length}');
      
      // 안전 경로의 모든 polyline을 생성하여 allPolylines에 추가
      for (int i = 0; i < safeRoads.length; i++) {
        final road = safeRoads[i];
        final vertexes = road['vertexes'] as List;
        
        // vertexes는 [시작점_경도, 시작점_위도, 도착점_경도, 도착점_위도] 순서
        if (vertexes.length >= 4) {
          final startLng = vertexes[0] as double;
          final startLat = vertexes[1] as double;
          final endLng = vertexes[2] as double;
          final endLat = vertexes[3] as double;
          
          print('안전 경로 Road $i: 시작점($startLat, $startLng) → 도착점($endLat, $endLng)');
          
          // 안전 경로용 Polyline 생성 (파란색 계열)
          final safePolyline = Polyline(
            polylineId: 'safe_route_segment_$i',
            points: [
              LatLng(startLat, startLng),
              LatLng(endLat, endLng),
            ],
            strokeColor: Colors.orange, // 주황색
            strokeOpacity: 0.8,
            strokeWidth: 4,
            strokeStyle: StrokeStyle.solid,
            zIndex: 2, // 기존 경로보다 위에 표시
          );
          
          allPolylines.add(safePolyline);
          print('안전 경로 Road $i polyline 생성 완료');
        }
      }
      
      // 모든 polyline을 한 번에 지도에 추가 (기존 경로 + 안전 경로)
      if (allPolylines.isNotEmpty) {
        await _mapController!.addPolyline(polylines: allPolylines);
        print('총 ${allPolylines.length}개의 polyline을 한 번에 추가 완료 (기존 경로 + 안전 경로)');
      }
      
      // 상태 업데이트
      setState(() {
        destinationMarker = destination_marker;
        originMarker = origin_marker;
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
