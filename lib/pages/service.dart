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
    final routeData = {"trans_id":"0198cb1cc26d7382be1bdb0fcb45a44c","routes":[{"result_code":0,"result_message":"길찾기 성공","summary":{"distance":862,"duration":786},"sections":[{"distance":862,"duration":786,"roads":[{"distance":18,"duration":16,"vertexes":[129.01543516363992,35.14641547489636,129.01553224300568,35.146279451596534]},{"distance":24,"duration":22,"vertexes":[129.01553224300568,35.146279451596534,129.01568362799128,35.14609790312368]},{"distance":15,"duration":14,"vertexes":[129.01568362799128,35.14609790312368,129.01578104255194,35.14598891875975]},{"distance":17,"duration":15,"vertexes":[129.01578104255194,35.14598891875975,129.01585606258516,35.145844066138864]},{"distance":38,"duration":34,"vertexes":[129.01585606258516,35.145844066138864,129.01589995510216,35.14584369815495,129.01617573977722,35.145958567439706,129.01624157863804,35.14595801528263]},{"distance":22,"duration":20,"vertexes":[129.01624157863804,35.14595801528263,129.01625187951623,35.14590384500331,129.01621783970643,35.14581399067061,129.01619533327133,35.14576910951208]},{"distance":22,"duration":20,"vertexes":[129.01619533327133,35.14576910951208,129.01640281396678,35.145686243493]},{"distance":11,"duration":20,"vertexes":[129.01640281396678,35.145686243493,129.01652351813303,35.14568523095833]},{"distance":32,"duration":29,"vertexes":[129.01652351813303,35.14568523095833,129.01645420548124,35.14540637897469]},{"distance":27,"duration":24,"vertexes":[129.01645420548124,35.14540637897469,129.01674991783023,35.145358828134036]},{"distance":49,"duration":44,"vertexes":[129.01674991783023,35.145358828134036,129.01727583962722,35.14529131616824]},{"distance":57,"duration":51,"vertexes":[129.01727583962722,35.14529131616824,129.01781250911222,35.14520568368772,129.01787845955374,35.14521414368979]},{"distance":49,"duration":44,"vertexes":[129.01787845955374,35.14521414368979,129.01793310028967,35.14519565672294,129.01840381797686,35.145101561671474]},{"distance":88,"duration":79,"vertexes":[129.01840381797686,35.145101561671474,129.01850257516384,35.14510073162422,129.01935689725602,35.1449673520313]},{"distance":23,"duration":21,"vertexes":[129.01935689725602,35.1449673520313,129.0192884746408,35.1447606060694]},{"distance":56,"duration":50,"vertexes":[129.0192884746408,35.1447606060694,129.01987966579938,35.1446474638959]},{"distance":7,"duration":6,"vertexes":[129.01987966579938,35.1446474638959,129.01986801822008,35.144593478050375]},{"distance":39,"duration":35,"vertexes":[129.01986801822008,35.144593478050375,129.02028589006764,35.144662072123076]},{"distance":50,"duration":45,"vertexes":[129.02028589006764,35.144662072123076,129.0203800344351,35.144291706230575,129.02037913449746,35.14421960197018]},{"distance":17,"duration":15,"vertexes":[129.02037913449746,35.14421960197018,129.02033344312514,35.14407576303629]},{"distance":14,"duration":13,"vertexes":[129.02033344312514,35.14407576303629,129.02029894974117,35.1439498577541]},{"distance":14,"duration":13,"vertexes":[129.02029894974117,35.1439498577541,129.02026445646814,35.1438239524577]},{"distance":13,"duration":12,"vertexes":[129.02026445646814,35.1438239524577,129.0202301882528,35.14371607321464]},{"distance":10,"duration":9,"vertexes":[129.0202301882528,35.14371607321464,129.02021876553525,35.14368011346402,129.0201852847213,35.143635325441934]},{"distance":12,"duration":11,"vertexes":[129.0201852847213,35.143635325441934,129.02018472238086,35.143590260271644,129.0201619894991,35.143527353791896]},{"distance":52,"duration":47,"vertexes":[129.0201619894991,35.143527353791896,129.0200151824502,35.143195072338536,129.02000286033717,35.14308700827933]},{"distance":86,"duration":77,"vertexes":[129.02000286033717,35.14308700827933,129.0204102017647,35.14319174657041,129.0204760383108,35.14319119215057,129.0208685816392,35.14298957815638]}]}]}]};
    
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
        [129.06259149197297, 35.15497591543021]
      ]
    };
    
    return jsonEncode(cameraData);
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
      );

      // 도착지 마커 생성
      final destination_marker = Marker(
        markerId: 'destination',
        latLng: destinationLatLng,
        infoWindowContent: '$destinationText (도착지)',
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
      
      // 모든 마커를 한 번에 추가 (출발지, 도착지, 카메라 위치)
      final allMarkers = [origin_marker, destination_marker, ...cameraMarkers];
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
