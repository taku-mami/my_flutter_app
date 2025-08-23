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

  /// 출발지/도착지 검색을 위한 자연어와 좌표 정보
  final List<Map<String, dynamic>> locationData = [
    {
      "localName": "개금2동예슬어린이집",
      "coord": [129.014987697039, 35.1460392279298]
    },
    {
      "localName": "개금대동아파트",
      "coord": [129.02072861028753, 35.14357891484248]
    }
  ];

  // 검색 결과를 저장할 변수들
  List<Map<String, dynamic>> _filteredOriginLocations = [];
  List<Map<String, dynamic>> _filteredDestinationLocations = [];

  // 입력 필드 컨트롤러
  final TextEditingController _originController = TextEditingController();
  final TextEditingController _destinationController = TextEditingController();

  // UI 컴포넌트 가시성 제어
  bool _isUIVisible = true;

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
    final routeData = {"trans_id":"0198cb1cc26d7382be1bdb0fcb45a44c","routes":[{"result_code":0,"result_message":"길찾기 성공","summary":{"distance":862,"duration":786},"sections":[{"distance":862,"duration":786,"roads":[{"distance":18,"duration":16,"vertexes":[129.014987697039,35.1460392279298,129.01471118884476,35.14594920440401]},{"distance":24,"duration":22,"vertexes":[129.01471118884476,35.14594920440401,129.01509293137448,35.14552380908105]},{"distance":15,"duration":14,"vertexes":[129.01509293137448,35.14552380908105,129.0153814714836,35.144989569791186]},{"distance":17,"duration":15,"vertexes":[129.0153814714836,35.144989569791186,129.0164038369906,35.145405117298246]},{"distance":38,"duration":34,"vertexes":[129.0164038369906,35.145405117298246,129.01623137201491,35.14452934541577]},{"distance":22,"duration":20,"vertexes":[129.01623137201491,35.14452934541577,129.01719597287052,35.1447160489488]},{"distance":22,"duration":20,"vertexes":[129.01719597287052,35.1447160489488,129.01918554020338,35.144423812369816]},{"distance":11,"duration":20,"vertexes":[129.01918554020338,35.144423812369816,129.0202446994892,35.14466298546256]},{"distance":32,"duration":29,"vertexes":[129.0202446994892,35.14466298546256,129.02038519338473,35.144243850346136]},{"distance":27,"duration":24,"vertexes":[129.02038519338473,35.144243850346136,129.0202164467861,35.14374200885604]},{"distance":49,"duration":44,"vertexes":[129.0202164467861,35.14374200885604,129.02053130755823,35.14360834016177]},{"distance":57,"duration":51,"vertexes":[129.02053130755823,35.14360834016177,129.02072861028753,35.14357891484248]}]}]}]};
    
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
                    129.014987697039,35.1460392279298,
                    129.01900153422724, 35.143859141427654,
                  ]
                },
                {
                  "distance": 41,
                  "duration": 37,
                  "vertexes": [
                    129.01900153422724, 35.143859141427654,
                    129.02072861028753,35.14357891484248
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
  
  /// 출발지 검색 필터링
  void _filterOriginLocations(String query) {
    if (query.isEmpty) {
      setState(() {
        _filteredOriginLocations = [];
      });
      return;
    }
    
    setState(() {
      _filteredOriginLocations = locationData
          .where((location) => location['localName'].toString().toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  /// 도착지 검색 필터링
  void _filterDestinationLocations(String query) {
    if (query.isEmpty) {
      setState(() {
        _filteredDestinationLocations = [];
      });
      return;
    }
    
    setState(() {
      _filteredDestinationLocations = locationData
          .where((location) => location['localName'].toString().toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  /// 카메라 좌표 정보를 반환하는 임시 함수 (하드코딩)
  String getCameraCoord() {
    // 하드코딩된 카메라 좌표 정보 반환
    final cameraData = {
      "coords": [
        [129.01900153422724, 35.143859141427654]
      ]
    };
    
    return jsonEncode(cameraData);
  }

  /// 경찰서 좌표 정보를 반환하는 임시 함수 (하드코딩)
  String getPoliceCoord() {
    // 하드코딩된 경찰서 좌표 정보 반환
    final policeData = {
      "coords": [
        [129.06259149197297, 35.15497591543021]
      ]
    };
    
    return jsonEncode(policeData);
  }
  
  /// 편의점 좌표 정보를 반환하는 임시 함수 (하드코딩)
  String getConvenienceStoreCoord() {
    // 하드코딩된 편의점 좌표 정보 반환
    final convenienceStoreData = {
      "coords": [
        [129.01633487113457, 35.14461098099456] // 이마트24 개금대명점
      ]
    };
    
    return jsonEncode(convenienceStoreData);
  }

  /// 보안등 좌표 정보를 반환하는 임시 함수 (하드코딩)
  String getSecurityLightCoord() {
    // 하드코딩된 보안등 좌표 정보 반환
    final securityLightData = {
      "coords": [
        [129.01894263047237, 35.14336222582966]
      ]
    };
    
    return jsonEncode(securityLightData);
  }

  void _selectDestination(BuildContext context) {
    // 출발지와 도착지가 선택되어 있는지 확인
    final originText = _originController.text.trim();
    final destinationText = _destinationController.text.trim();
    
    if (originText.isEmpty || destinationText.isEmpty) {
      // 출발지 또는 도착지가 선택되지 않은 경우
      String missingField = '';
      if (originText.isEmpty && destinationText.isEmpty) {
        missingField = '출발지와 도착지';
      } else if (originText.isEmpty) {
        missingField = '출발지';
      } else {
        missingField = '도착지';
      }
      
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('입력 확인'),
          content: Text('$missingField가 선택되어 있지 않습니다.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('확인'),
            ),
          ],
        ),
      );
      return;
    }
    
    // 출발지와 도착지가 모두 선택된 경우에만 안전 경로 찾기 다이얼로그 표시
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('안전 경로 찾기'),
        content: Text('출발지: $originText\n도착지: $destinationText\n\n안전 경로를 찾으시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // 안전 경로 찾기 처리
              _handleDestinationSelection(context);
            },
            child: const Text('찾기'),
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

      // 선택된 출발지와 도착지 텍스트 가져오기
      final originText = _originController.text.trim();
      final destinationText = _destinationController.text.trim();
      
      // locationData에서 선택된 위치의 좌표 찾기
      LatLng? originLatLng;
      LatLng? destinationLatLng;
      
      for (final location in locationData) {
        if (location['localName'] == originText) {
          final coords = location['coord'] as List;
          originLatLng = LatLng(coords[1] as double, coords[0] as double);
        }
        if (location['localName'] == destinationText) {
          final coords = location['coord'] as List;
          destinationLatLng = LatLng(coords[1] as double, coords[0] as double);
        }
      }
      
      if (originLatLng == null || destinationLatLng == null) {
        print('선택된 위치의 좌표를 찾을 수 없습니다.');
        return;
      }

      // 출발지 마커 생성
      final origin_marker = Marker(
        markerId: 'origin',
        latLng: originLatLng,
        infoWindowContent: '$originText (출발지)',
        width: 40,
        height: 40,
      );

      // 도착지 마커 생성
      final destination_marker = Marker(
        markerId: 'destination',
        latLng: destinationLatLng,
        infoWindowContent: '$destinationText (도착지)',
        width: 40,
        height: 40,
      );
      
      // getCameraCoord 함수를 사용하여 카메라 좌표 정보 가져오기
      final cameraJson = getCameraCoord();
      final cameraData = jsonDecode(cameraJson);
      final cameraCoords = cameraData['coords'] as List;
      
      // 카메라 좌표에 마커 추가
      final List<Marker> cameraMarkers = [];
      for (int i = 0; i < cameraCoords.length; i++) {
        final coord = cameraCoords[i] as List;
        final lng = coord[0] as double;
        final lat = coord[1] as double;
        
        final cameraMarker = Marker(
          markerId: 'camera_$i',
          latLng: LatLng(lat, lng),
          infoWindowContent: '카메라 위치 $i',
        );
        cameraMarkers.add(cameraMarker);
        print('카메라 마커 $i 생성: ($lat, $lng)');
      }

      // 편의점 마커 생성
      final convenienceStoreJson = getConvenienceStoreCoord();
      final convenienceStoreData = jsonDecode(convenienceStoreJson);
      final convenienceStoreCoords = convenienceStoreData['coords'] as List;

      // 편의점 좌표에 마커 추가 (이미지 마커 사용)
      final List<Marker> convenienceStoreMarkers = [];
      for (int i = 0; i < convenienceStoreCoords.length; i++) {
        final coord = convenienceStoreCoords[i] as List;
        final lng = coord[0] as double;
        final lat = coord[1] as double;

        final convenienceStoreMarker = Marker(
          markerId: 'convenience_store_$i',
          latLng: LatLng(lat, lng),
          infoWindowContent: '편의점 위치 $i',
          width: 40,
          height: 40,
        );
        convenienceStoreMarkers.add(convenienceStoreMarker);
        print('편의점 마커 $i 생성: ($lat, $lng)');
      }
      
      // 출발지 마커에 이미지 추가 (비동기 처리)
      try {
        final originMarkerIcon = await MarkerIcon.fromAsset('assets/images/출발지.png');
        origin_marker.icon = originMarkerIcon;
        print('출발지 마커 이미지 적용 완료');
      } catch (e) {
        print('출발지 마커 이미지 로드 실패: $e');
      }
      
      // 도착지 마커에 이미지 추가 (비동기 처리)
      try {
        final destinationMarkerIcon = await MarkerIcon.fromAsset('assets/images/도착지.png');
        destination_marker.icon = destinationMarkerIcon;
        print('도착지 마커 이미지 적용 완료');
      } catch (e) {
        print('도착지 마커 이미지 로드 실패: $e');
      }
      
      // 편의점 마커에 이미지 추가 (비동기 처리)
      for (int i = 0; i < convenienceStoreMarkers.length; i++) {
        try {
          final markerIcon = await MarkerIcon.fromAsset('assets/images/편의점.png');
          convenienceStoreMarkers[i].icon = markerIcon;
        } catch (e) {
          print('편의점 마커 이미지 로드 실패: $e');
        }
      }      
      
      // 모든 마커를 한 번에 추가 (출발지, 도착지, 카메라 위치)
      final allMarkers = [origin_marker, destination_marker, ...cameraMarkers, ...convenienceStoreMarkers];
      await _mapController!.addMarker(markers: allMarkers);
      print('총 ${allMarkers.length}개의 마커 추가 완료 (출발지, 도착지, 카메라 위치)');

      
      // getWalkRoute 함수를 사용하여 경로 정보 가져오기
      final routeJson = getWalkRoute(
        origin: originLatLng,
        destination: destinationLatLng,
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
            strokeColor: Colors.grey, // 회색 계열
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
        origin: originLatLng,
        destination: destinationLatLng,
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
            strokeColor: Colors.green, // 초록색
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

      // 지도 중심을 출발지와 도착지의 중간 지점으로 이동하고 줌 레벨 조정
      final centerLat = (originLatLng.latitude + destinationLatLng.latitude) / 2;
      final centerLng = (originLatLng.longitude + destinationLatLng.longitude) / 2;
      final centerPoint = LatLng(centerLat, centerLng);
      
      _mapController!.setCenter(centerPoint);
      _mapController!.setLevel(4); // 경로를 잘 볼 수 있도록 줌 레벨 조정
      print('지도 중심 이동 및 줌 레벨 조정 완료');
      
      print('$originText에서 $destinationText까지의 경로 생성됨');

      // 컴포넌트 가시성 제어
      _isUIVisible = false;
    } catch (e) {
      print('마커 생성 오류: $e');
      print('오류 스택 트레이스: ${StackTrace.current}');
    }
  }

  @override
  void dispose() {
    _originController.dispose();
    _destinationController.dispose();
    super.dispose();
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
                            center: LatLng(35.1691716212143, 129.13625616255), // 벡스코 좌표
                            currentLevel: 5, // 지도의 확대 레벨
                            zoomControl: true, // 확대 축소 버튼 표시
                          ),
                          // 상단 출발지/도착지 입력 컴포넌트 (지도가 준비되고 UI가 보일 때만 표시)
                          if (_isMapReady && _isUIVisible)
                            Positioned(
                              top: 20.0,
                              left: 35.0, // 좌우 여백을 조금 더 늘려서 너비를 아주 살짝 줄임
                              right: 35.0, // 좌우 여백을 조금 더 늘려서 너비를 아주 살짝 줄임
                              child: Container(
                                padding: const EdgeInsets.all(12.0), // 패딩을 16에서 12로 줄임
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10.0), // 모서리 반경도 살짝 줄임
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 6, // 그림자도 살짝 줄임
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  children: [
                                    // 출발지 입력 필드
                                    SizedBox(
                                      height: 40.0, // 높이를 절반으로 줄임 (기존 약 80에서 40으로)
                                      child: TextField(
                                        controller: _originController,
                                        style: const TextStyle(color: Colors.black), // 입력 텍스트 색상을 검은색으로 설정
                                        onChanged: _filterOriginLocations,
                                        decoration: InputDecoration(
                                          hintText: '출발지 입력',
                                          prefixIcon: const Icon(Icons.location_on, color: Colors.green, size: 18), // 아이콘 크기도 줄임
                                          filled: true,
                                          fillColor: Colors.grey[50],
                                          contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8), // 내부 여백 줄임
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(6.0), // 테두리 모서리 줄임
                                            borderSide: BorderSide(color: Colors.grey[300]!),
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(6.0),
                                            borderSide: BorderSide(color: Colors.grey[300]!),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(6.0),
                                            borderSide: const BorderSide(color: Colors.blue, width: 1.5), // 포커스 테두리도 줄임
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 8.0), // 필드 간 간격도 줄임
                                    // 도착지 입력 필드
                                    SizedBox(
                                      height: 40.0, // 높이를 절반으로 줄임
                                      child: TextField(
                                        controller: _destinationController,
                                        style: const TextStyle(color: Colors.black), // 입력 텍스트 색상을 검은색으로 설정
                                        onChanged: _filterDestinationLocations,
                                        decoration: InputDecoration(
                                          hintText: '도착지 입력',
                                          prefixIcon: const Icon(Icons.location_on, color: Colors.red, size: 18), // 아이콘 크기도 줄임
                                          filled: true,
                                          fillColor: Colors.grey[50],
                                          contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8), // 내부 여백 줄임
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(6.0), // 테두리 모서리 줄임
                                            borderSide: BorderSide(color: Colors.grey[300]!),
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(6.0),
                                            borderSide: BorderSide(color: Colors.grey[300]!),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(6.0),
                                            borderSide: const BorderSide(color: Colors.blue, width: 1.5), // 포커스 테두리도 줄임
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            // 출발지 후보 리스트 (입력 컴포넌트 위에 덮어씌워짐)
                            if (_isMapReady && _isUIVisible)
                              Positioned(
                                top: 72.0, // 20 + 12 + 40 (상단 여백 + 패딩 + 출발지 입력 필드 높이)
                                left: 35.0,
                                right: 35.0,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(6.0),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: ListView.builder(
                                    shrinkWrap: true,
                                    physics: const NeverScrollableScrollPhysics(), // 드래그 방지
                                    itemCount: _filteredOriginLocations.length,
                                    itemBuilder: (context, index) {
                                      final location = _filteredOriginLocations[index];
                                      return ListTile(
                                        dense: true,
                                        title: Text(
                                          location['localName'],
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Colors.black, // 글씨 색상을 검은색으로 설정
                                          ),
                                        ),
                                        onTap: () {
                                          // 출발지 선택 시 처리
                                          print('출발지 선택: ${location['localName']}');
                                          _originController.text = location['localName'];
                                          setState(() {
                                            _filteredOriginLocations = [];
                                          });
                                        },
                                      );
                                    },
                                  ),
                                ),
                              ),
                            // 도착지 후보 리스트 (입력 컴포넌트 위에 덮어씌워짐)
                            if (_isMapReady && _isUIVisible)
                              Positioned(
                                top: 120.0, // 20 + 12 + 40 + 8 + 40 (상단 여백 + 패딩 + 출발지 + 간격 + 도착지 입력 필드 높이)
                                left: 35.0,
                                right: 35.0,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(6.0),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: ListView.builder(
                                    shrinkWrap: true,
                                    physics: const NeverScrollableScrollPhysics(), // 드래그 방지
                                    itemCount: _filteredDestinationLocations.length,
                                    itemBuilder: (context, index) {
                                      final location = _filteredDestinationLocations[index];
                                      return ListTile(
                                        dense: true,
                                        title: Text(
                                          location['localName'],
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Colors.black, // 글씨 색상을 검은색으로 설정
                                          ),
                                        ),
                                        onTap: () {
                                          // 도착지 선택 시 처리
                                          print('도착지 선택: ${location['localName']}');
                                          _destinationController.text = location['localName'];
                                          setState(() {
                                            _filteredDestinationLocations = [];
                                          });
                                        },
                                      );
                                    },
                                  ),
                                ),
                              ),
                            
                            // 안전 경로 찾기 버튼 (지도가 준비되고 UI가 보일 때만 표시)
                            if (_isMapReady && _isUIVisible)
                              Positioned(
                                left: 0,
                                right: 0,
                                bottom: MediaQuery.of(context).size.height * 0.05, // 하단에서 5% 위
                                child: Center(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(8),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.2),
                                          blurRadius: 8,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Material(
                                      color: Colors.transparent,
                                      child: InkWell(
                                        onTap: () {
                                          _selectDestination(context);
                                        },
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
                                                '안전 경로 찾기',
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
