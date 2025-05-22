package com.example.sleeptight.wear.presentation.components

import androidx.compose.animation.AnimatedVisibility
import androidx.compose.animation.core.tween
import androidx.compose.animation.fadeIn
import androidx.compose.animation.fadeOut
import androidx.compose.foundation.Image
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.material.MaterialTheme
import androidx.compose.material.Text
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.wear.compose.material.Button
import androidx.wear.compose.material.ButtonDefaults
import androidx.wear.compose.material.Scaffold
import androidx.wear.compose.material.TimeText
import androidx.wear.compose.material.Vignette
import androidx.wear.compose.material.VignettePosition
import com.example.sleeptight.wear.R
import com.example.sleeptight.wear.presentation.components.chart.CircularProgressBar
import com.example.sleeptight.wear.presentation.viewmodel.HealthViewModel
import com.google.accompanist.pager.ExperimentalPagerApi
import com.google.accompanist.pager.HorizontalPager
import com.google.accompanist.pager.HorizontalPagerIndicator
import com.google.accompanist.pager.rememberPagerState
import kotlinx.coroutines.delay
import kotlinx.coroutines.launch

/**
 * 앱 메인 화면
 */
@OptIn(ExperimentalPagerApi::class)
@Composable
fun MainScreen(viewModel: HealthViewModel) {
    // 헬스 데이터 상태 가져오기
    val healthData by viewModel.healthData.collectAsState()

    // 색상 정의 - 더 선명한 색상으로 조정
    val calorieColor = Color(0xFFFF5B6A)  // 빨간색 (칼로리)
    val stepColor = Color(0xFF4AFFB8)     // 연두색 (걸음 수)
    val waterColor = Color(0xFF4DB1FF)    // 파란색 (물)
    val caffeineColor = Color(0xFFAC8FFF)  // 보라색 (카페인)

    // 코루틴 스코프 및 페이저 상태 설정
    val coroutineScope = rememberCoroutineScope()
    val pagerState = rememberPagerState()

    // 앱 시작 시 데이터 가져오기
    LaunchedEffect(key1 = true) {
        if (viewModel.wearableRepository != null) {
            viewModel.wearableRepository.requestHealthData()
        }
    }

    Scaffold(
        timeText = { TimeText() },
        vignette = { Vignette(vignettePosition = VignettePosition.TopAndBottom) },
        positionIndicator = {
            // 커스텀 페이지 인디케이터를 Box 안에 배치
            Box(
                modifier = Modifier.fillMaxSize(),
                contentAlignment = Alignment.BottomCenter
            ) {
                HorizontalPagerIndicator(
                    pagerState = pagerState,
                    modifier = Modifier.padding(bottom = 22.dp),
                    activeColor = Color.White,
                    inactiveColor = Color.Gray.copy(alpha = 0.3f),
                    indicatorWidth = 6.dp,
                    indicatorHeight = 6.dp,
                    spacing = 4.dp
                )
            }
        },
        modifier = Modifier.background(Color.Black)
    ) {
        // 페이저 구현
        HorizontalPager(
            count = 4,  // 4개 항목: 칼로리, 걸음 수, 물, 카페인
            state = pagerState,
            modifier = Modifier.fillMaxSize()
        ) { page ->
            when (page) {
                // 활동량(소모 칼로리)
                0 -> MetricPage(
                    title = "활동량",
                    currentValue = healthData.calories,
                    targetValue = healthData.caloriesGoal,
                    progress = healthData.getCaloriesProgress(),
                    progressColor = calorieColor,
                    unit = "kcal"
                )

                // 걸음 수
                1 -> MetricPage(
                    title = "걸음 수",
                    currentValue = healthData.steps,
                    targetValue = healthData.stepsGoal,
                    progress = healthData.getStepsProgress(),
                    progressColor = stepColor,
                    unit = "걸음"
                )

                // 물
                2 -> MetricPage(
                    title = "물 섭취량",
                    currentValue = healthData.water,
                    targetValue = healthData.waterGoal,
                    progress = healthData.getWaterProgress(),
                    progressColor = waterColor,
                    unit = "ml",
                    isEditable = true,
                    step = 200,  // 200ml 단위로 조절로 수정
                    onValueChange = { value ->
                        coroutineScope.launch {
                            viewModel.updateWaterIntake(value)
                        }
                    }
                )

                // 카페인
                3 -> MetricPage(
                    title = "카페인",
                    currentValue = healthData.caffeine,
                    targetValue = healthData.caffeineGoal,
                    progress = healthData.getCaffeineProgress(),
                    progressColor = caffeineColor,
                    unit = "mg",
                    isEditable = true,
                    step = 50,  // 50mg 단위로 조절 (기존과 동일)
                    onValueChange = { value ->
                        coroutineScope.launch {
                            viewModel.updateCaffeineIntake(value)
                        }
                    }
                )
            }
        }
    }
}

/**
 * 메트릭 페이지
 */
@Composable
fun MetricPage(
    title: String,
    currentValue: Float,
    targetValue: Float,
    progress: Float,
    progressColor: Color,
    unit: String,
    isEditable: Boolean = false,
    step: Float = 0f,
    onValueChange: (Float) -> Unit = {}
) {
    Column(
        modifier = Modifier.fillMaxSize(),
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.Center
    ) {
        // 타이틀
        Row(
            verticalAlignment = Alignment.CenterVertically,
            horizontalArrangement = Arrangement.Center,
            modifier = Modifier.padding(bottom = 8.dp)
        ) {
            Text(
                text = title,
                fontSize = 16.sp,
                fontWeight = FontWeight.Bold,
                color = progressColor
            )
        }
        
        // 차트
        Box(
            contentAlignment = Alignment.Center,
            modifier = Modifier
                .size(120.dp)
                .padding(8.dp)
        ) {
            CircularProgressBar(
                percentage = progress,
                color = progressColor
            )
            
            Column(
                horizontalAlignment = Alignment.CenterHorizontally,
                verticalArrangement = Arrangement.Center
            ) {
                Text(
                    text = "${currentValue.toInt()} $unit",
                    fontSize = 12.sp,
                    textAlign = TextAlign.Center,
                    modifier = Modifier.padding(4.dp)
                )
            }
        }
    }
} 