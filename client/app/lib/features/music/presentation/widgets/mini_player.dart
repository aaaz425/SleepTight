import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sleep_tight/core/config/theme/color.dart'; // 경로 확인
import 'package:sleep_tight/core/config/theme/text_styles.dart'; // 경로 확인
import 'package:sleep_tight/features/music/presentation/providers/audio_controller.dart';
// MusicModel import (필요하다면, audioState.music에서 이미 MusicModel 타입이므로 직접 사용)
// import 'package:sleep_tight/features/music/domain/entity/music_model.dart';

class MiniPlayer extends ConsumerWidget {
  const MiniPlayer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final audioState = ref.watch(audioControllerProvider);
    final music = audioState.music; // MusicModel 타입
    final audioController = ref.read(
      audioControllerProvider.notifier,
    ); // notifier는 read로

    if (music == null) return const SizedBox.shrink();

    return Container(
      decoration: BoxDecoration(
        color: AppColors.gray01,
        border: Border(
          top: BorderSide(color: AppColors.font1, width: 0.25),
          bottom: BorderSide(color: AppColors.font1, width: 0.25),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 52,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                // 앨범 아트 - 터치 시 패널이 닫히는 문제가 없다면 그대로 두거나,
                // 만약 이 부분을 터치해도 문제가 발생한다면 GestureDetector로 감싸세요.
                // 여기서는 일단 그대로 둡니다.
                // const SizedBox(width: 12), // 원본에 있었는지 확인 (없었다면 제거)
                GestureDetector(
                  // 앨범 아트도 터치 영역으로 간주될 수 있으므로 추가
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    // 앨범 아트 탭 시 동작 (예: 패널 열기 - PanelController 사용)
                    // SlidingUpPanel의 controller를 통해 panel.open() 등 호출
                    debugPrint("MiniPlayer: Album Art Tapped");
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: Image.network(
                      music.coverUrl, // MusicModel에 coverUrl이 있다고 가정
                      width: 30,
                      height: 30,
                      fit: BoxFit.cover,
                      errorBuilder:
                          (ctx, err, st) => Icon(
                            Icons.broken_image,
                            color: AppColors.gray06,
                            size: 30, // 이미지 크기와 맞춤
                          ),
                    ),
                  ),
                ),
                const SizedBox(width: 12), // 앨범아트와 제목 사이 간격 (기존 4에서 조정)
                // 곡 제목 - 터치 시 패널이 닫히는 문제가 없다면 그대로 두거나,
                // 만약 이 부분을 터치해도 문제가 발생한다면 GestureDetector로 감싸세요.
                Expanded(
                  child: GestureDetector(
                    // 곡 제목 영역도 터치 영역으로 간주
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      // 곡 제목 탭 시 동작 (예: 패널 열기)
                      debugPrint("MiniPlayer: Title Tapped");
                    },
                    child: Text(
                      music.title,
                      style: AppTextStyles.captionC1Rg(
                        color: AppColors.white,
                      ).copyWith(
                        decoration: TextDecoration.none,
                      ), // TextDecoration.none은 기본값
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1, // 한 줄로 제한
                    ),
                  ),
                ),
                // const SizedBox(width: 4), // 제목과 버튼 사이 간격 (아래 버튼 패딩으로 조절 가능)

                // 재생/일시정지 버튼 - GestureDetector로 감싸서 이벤트 소비 명시
                GestureDetector(
                  behavior: HitTestBehavior.opaque, // !!! 핵심: 이벤트 소비 !!!
                  onTap: () {
                    debugPrint(
                      "MiniPlayer: Play/Pause button tapped via GestureDetector",
                    );
                    if (audioState.isPlaying) {
                      audioController.pause();
                    } else {
                      // music 객체가 있으므로 play 또는 resume
                      // play는 처음부터 재생, resume은 이어서 재생
                      // 현재 로직은 play(music)이므로, music 객체를 다시 전달하여 재생
                      audioController.play(music);
                      // 만약 이어재생을 원한다면 audioController.resume();
                    }
                  },
                  child: Container(
                    // InkWell 효과를 원하면 Material > InkWell 구조 유지 가능
                    padding: const EdgeInsets.all(8), // 터치 영역 확보 및 시각적 패딩
                    // borderRadius: BorderRadius.circular(4), // InkWell 사용 시 필요
                    // color: Colors.transparent, // Material 사용 시 필요
                    child: SvgPicture.asset(
                      audioState.isPlaying
                          ? 'assets/icons/pause_solid.svg'
                          : 'assets/icons/play_solid.svg',
                      colorFilter: ColorFilter.mode(
                        AppColors.white,
                        BlendMode.srcIn,
                      ),
                      width: 24, // 아이콘 크기 명시 (SVG에 따라 조절)
                      height: 24, // 아이콘 크기 명시
                    ),
                  ),
                ),
                // const SizedBox(width: 8), // 오른쪽 끝 간격 (Padding으로 조절됨)
              ],
            ),
          ),
        ),
      ),
    );
  }
}
