import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:sleep_tight/core/config/theme/color.dart';
import 'package:sleep_tight/core/config/theme/text_styles.dart';
import 'package:sleep_tight/features/music/presentation/providers/audio_controller.dart';
import 'package:sleep_tight/shared/widgets/shell_bottom_nav_bar.dart';
import 'package:sleep_tight/features/music/presentation/widgets/mini_player.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class ShellScreen extends ConsumerWidget {
  final Widget body;
  final PreferredSizeWidget? header;
  final bool hasBottomNav;
  const ShellScreen({
    super.key,
    required this.body,
    this.header,
    this.hasBottomNav = true,
  });

  int _calculateSelectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    final idx = ShellBottomNavBar.navItems.indexWhere(
      (item) => location.startsWith(item.route),
    );
    return idx == -1 ? 0 : idx;
  }

  void _onItemTapped(int index, BuildContext context) {
    GoRouter.of(context).go(ShellBottomNavBar.navItems[index].route);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 선택된 음악이 있으면 미니 플레이어 표시
    final hasPlayer = ref.watch(
      audioControllerProvider.select((s) => s.music != null),
    );
    final currentIndex = _calculateSelectedIndex(context);

    Widget? bottomNav;
    if (hasBottomNav) {
      bottomNav = Theme(
        data: Theme.of(context).copyWith(
          splashFactory: NoSplash.splashFactory,
          highlightColor: Colors.transparent,
        ),
        child: ShellBottomNavBar(
          currentIndex: currentIndex,
          onTap: (index) => _onItemTapped(index, context),
        ),
      );
    }

    return SlidingUpPanel(
      margin: EdgeInsets.only(
        bottom: hasBottomNav ? kBottomNavigationBarHeight : 0,
      ),
      minHeight: hasPlayer ? 52 : 0,
      maxHeight: MediaQuery.of(context).size.height,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      collapsed: hasPlayer ? const MiniPlayer() : const SizedBox.shrink(),
      panelBuilder: (sc) => FullscreenPlayer(scrollController: sc),
      body: Scaffold(
        appBar: header,
        body: body,
        bottomNavigationBar: hasBottomNav ? bottomNav : null,
      ),
    );
  }
}

/// 풀스크린 플레이어
class FullscreenPlayer extends ConsumerWidget {
  final ScrollController scrollController;
  const FullscreenPlayer({super.key, required this.scrollController});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final music = ref.watch(audioControllerProvider).music;

    // 음악 정보가 없으면 빈 위젯 반환
    if (music == null) {
      return const SizedBox.shrink();
    }

    // 블러 강도 설정
    const double blurSigma = 15.0; // 블러 강도를 원하는 대로 조절하세요.

    return Stack(
      fit: StackFit.expand, // Stack의 자식들이 가용한 공간을 모두 채우도록 설정
      children: [
        // 1. 배경 이미지 레이어
        if (music.coverUrl != null && music.coverUrl!.isNotEmpty)
          Image.network(
            music.coverUrl!,
            fit: BoxFit.cover, // 이미지가 위젯 경계를 꽉 채우도록 설정 (비율 유지, 잘릴 수 있음)
            width: double.infinity, // 너비를 최대로
            height: double.infinity, // 높이를 최대로
            // 이미지 로딩 중 및 오류 발생 시 처리 (선택 사항이지만 권장)
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child; // 로딩 완료
              // 로딩 중에는 검은색 배경 또는 다른 플레이스홀더 표시 가능
              return Container(color: AppColors.gray01);
            },
            errorBuilder: (context, error, stackTrace) {
              // 이미지 로드 실패 시 검은색 배경 표시
              return Container(color: AppColors.gray01);
            },
          )
        else
          // 커버 URL이 없거나 비어있을 경우 검은색 배경
          Container(color: AppColors.gray01),

        // 2. 블러 효과 레이어
        // BackdropFilter는 자신보다 아래에 있는 위젯(여기서는 배경 이미지)에 필터를 적용합니다.
        BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
          child: Container(
            // BackdropFilter가 효과를 적용할 영역을 제공하기 위해 필요합니다.
            // 약간의 투명도를 가진 검은색을 덮으면 가독성에 도움이 될 수 있습니다.
            color: Colors.black.withValues(
              alpha: 0.7,
            ), // 필요에 따라 투명도 조절 (0.0은 색상 없음)
          ),
        ),

        // 3. 전경 콘텐츠 레이어 (스크롤 가능한 UI 요소들)
        SingleChildScrollView(
          controller: scrollController,
          child: Column(
            children: [
              const SizedBox(height: 12), // 상단 여백
              // 드래그 핸들
              // Container(
              //   width: 40,
              //   height: 4,
              //   decoration: BoxDecoration(
              //     // 핸들 색상이 블러된 배경 위에서 잘 보이도록 조정 필요할 수 있음
              //     color: AppColors.gray04,
              //     borderRadius: BorderRadius.circular(2),
              //   ),
              // ),
              // const SizedBox(height: 20), // 핸들 아래 여백
              SizedBox(height: 24),
              // TODO: 풀스크린 UI 구현 (앨범아트, 제목, 슬라이더, 컨트롤러 등)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 24,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          music.title,
                          style: AppTextStyles.titleT3Sb(
                            color: AppColors.white,
                          ).copyWith(decoration: TextDecoration.none),
                        ),
                        SvgPicture.asset(
                          'assets/icons/chevron_down.svg',
                          width: 28,
                          height: 28,
                          colorFilter: ColorFilter.mode(
                            AppColors.white,
                            BlendMode.srcIn,
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 120),

                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.network(
                        music.coverUrl,
                        fit: BoxFit.cover,
                        width: 320,
                        height: 320,
                      ),
                    ),

                    // 재생 슬라이더. 전체 재생 시간과 현재 재생 시간을 표시
                    SizedBox(height: 30),
                    // 재생 버튼/일시정지 버튼
                    ElevatedButton(
                      onPressed: () {
                        final notifier = ref.read(
                          audioControllerProvider.notifier,
                        );
                        final isPlaying =
                            ref.read(audioControllerProvider).isPlaying;
                        if (isPlaying) {
                          notifier.pause();
                        } else {
                          notifier.play(music, context);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: const CircleBorder(),
                        minimumSize: const Size(48, 48), // 버튼 최소 크기
                        padding: const EdgeInsets.all(12), // 아이콘 주변 여백
                      ),
                      child: SvgPicture.asset(
                        ref.watch(
                              audioControllerProvider.select(
                                (s) => s.isPlaying,
                              ),
                            )
                            ? 'assets/icons/pause_solid.svg'
                            : 'assets/icons/play_solid.svg',
                        width: 24,
                        height: 24,
                        colorFilter: const ColorFilter.mode(
                          AppColors.white,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
