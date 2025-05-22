package com.example.sleeptight.wear.presentation.components.chart

import androidx.compose.animation.core.animateFloatAsState
import androidx.compose.animation.core.tween
import androidx.compose.foundation.Canvas
import androidx.compose.foundation.layout.size
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.geometry.Size
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.StrokeCap
import androidx.compose.ui.graphics.drawscope.Stroke
import androidx.compose.ui.unit.dp

/**
 * 원형 프로그레스 바 컴포넌트
 */
@Composable
fun CircularProgressBar(
    percentage: Float,
    color: Color,
    modifier: Modifier = Modifier.size(100.dp),
    strokeWidth: Float = 12f,
    animDuration: Int = 1000,
    animDelay: Int = 0
) {
    // 애니메이션 관련 상태 관리
    var animationPlayed by remember { mutableStateOf(false) }
    val currentPercentage = animateFloatAsState(
        targetValue = if (animationPlayed) percentage else 0f,
        animationSpec = tween(
            durationMillis = animDuration,
            delayMillis = animDelay
        ),
        label = "progress_animation"
    )

    // 컴포넌트가 처음 그려질 때 애니메이션 시작
    LaunchedEffect(key1 = true) {
        animationPlayed = true
    }

    // 원형 프로그레스 바 그리기
    Canvas(modifier = modifier) {
        // 배경 원 그리기 (회색 원)
        drawArc(
            color = Color.LightGray.copy(alpha = 0.3f),
            startAngle = -90f,
            sweepAngle = 360f,
            useCenter = false,
            size = Size(size.width, size.height),
            style = Stroke(width = strokeWidth, cap = StrokeCap.Round)
        )

        // 진행 원 그리기 (색상이 있는 원)
        drawArc(
            color = color,
            startAngle = -90f,
            sweepAngle = 360 * currentPercentage.value,
            useCenter = false,
            size = Size(size.width, size.height),
            style = Stroke(width = strokeWidth, cap = StrokeCap.Round)
        )

        // 프로그레스 원의 끝에 작은 원 표시
        val angleInRadians = Math.toRadians((-90 + 360 * currentPercentage.value).toDouble())
        val radius = size.width / 2
        val dotX = (radius + radius * Math.cos(angleInRadians)).toFloat()
        val dotY = (radius + radius * Math.sin(angleInRadians)).toFloat()

        if (currentPercentage.value > 0f) {
            drawCircle(
                color = color,
                radius = strokeWidth / 2,
                center = Offset(dotX, dotY)
            )
        }
    }
} 