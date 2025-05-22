package com.example.wear.presentation.components

import android.content.Context
import android.os.Build
import android.os.VibrationEffect
import android.os.Vibrator
import android.os.VibratorManager
import androidx.compose.animation.core.Animatable
import androidx.compose.animation.core.FastOutSlowInEasing
import androidx.compose.animation.core.tween
import androidx.compose.foundation.Canvas
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.interaction.MutableInteractionSource
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxHeight
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.runtime.Composable
import androidx.compose.runtime.DisposableEffect
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.rememberCoroutineScope
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.geometry.Size
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.StrokeCap
import androidx.compose.ui.graphics.drawscope.DrawScope
import androidx.compose.ui.graphics.drawscope.Stroke
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.wear.compose.material.MaterialTheme
import androidx.wear.compose.material.Text

/**
 * 항목별 페이지 컴포넌트
 */
@Composable
fun MetricPage(
    title: String,
    currentValue: Int,
    targetValue: Int,
    progress: Float,
    progressColor: Color,
    unit: String = "",
    isEditable: Boolean = false,
    step: Int = 0,
    onValueChange: ((Int) -> Unit)? = null,
    modifier: Modifier = Modifier
) {
    // 코루틴 스코프 및 컨텍스트
    val coroutineScope = rememberCoroutineScope()
    val context = LocalContext.current
    
    // 수정 가능한 항목인 경우 현재 값과 진행률을 상태로 관리
    var editableValue by remember { mutableStateOf(currentValue) }
    var displayProgress by remember { mutableStateOf(progress) }
    
    // 현재 값이 변경될 때마다 편집 값 업데이트
    LaunchedEffect(currentValue) {
        // 모바일에서 받은 값이 우선이므로 현재 값으로 즉시 갱신
        editableValue = currentValue
        // 진행률도 함께 업데이트
        displayProgress = (currentValue.toFloat() / targetValue).coerceIn(0f, 1f)
    }
    
    // 진동을 한 번만 발생시키기 위한 상태
    var hasVibrated by remember { mutableStateOf(false) }
    
    // 표시할 수치와 진행률 계산
    val displayValue = if (isEditable) editableValue else currentValue
    // 버튼으로 값 수정 시 진행률 계산
    if (isEditable) {
        displayProgress = (displayValue.toFloat() / targetValue).coerceIn(0f, 1f)
    }
    
    // 화면에서 나갈 때 현재 편집 값을 저장하기 위한 효과
    DisposableEffect(Unit) {
        onDispose {
            // 화면을 떠날 때 변경된 값이 있으면 콜백을 통해 저장
            if (isEditable && editableValue != currentValue) {
                onValueChange?.invoke(editableValue)
            }
        }
    }
    
    // 애니메이션이 적용된 진행률
    val animatedProgress = remember { Animatable(0f) }
    
    // 진행률이 변경될 때마다 애니메이션 적용
    LaunchedEffect(key1 = displayProgress) {
        animatedProgress.animateTo(
            targetValue = displayProgress,
            animationSpec = tween(
                durationMillis = 500, 
                easing = FastOutSlowInEasing
            )
        )
        
        // 100% 도달 시 진동 발생
        if (displayProgress >= 1.0f && !hasVibrated) {
            vibrate(context)
            hasVibrated = true
        } else if (displayProgress < 1.0f) {
            hasVibrated = false
        }
    }
    
    // 화면 배경 설정
    Box(
        contentAlignment = Alignment.Center,
        modifier = modifier
            .fillMaxSize()
            .background(Color.Black.copy(alpha = 0.8f))
    ) {
        // 원형 진행 표시기
        Canvas(
            modifier = Modifier
                .fillMaxSize()
                .padding(8.dp)
        ) {
            val outerRadius = size.minDimension / 2.1f // 그래프를 바깥쪽으로 이동
            val strokeWidth = 6.dp.toPx() // 그래프 두께 줄임
            
            // 각도 기준은 3시 방향(0도)에서 시작, 시계 방향으로 증가
            // 12시 방향은 270도, 1시 방향은 약 300도, 11시 방향은 약 240도
            val startAngle = 300f  // 1시 방향 (12시에서 조금 우측)
            val endAngle = 240f    // 11시 방향 (12시에서 조금 좌측)
            
            // 시계 방향으로 그래프를 그리기 위한 각도 계산
            // 1시에서 11시까지 시계 방향으로 가려면 300도에서 240+360도(시계 한 바퀴)까지
            val totalAngle = (endAngle + 360f - startAngle) % 360f // 약 300도
            
            // 배경 호 그리기 (12시 부분을 제외한 전체 영역)
            drawArc(
                color = Color.DarkGray.copy(alpha = 0.2f),
                startAngle = startAngle,
                sweepAngle = totalAngle,
                useCenter = false,
                style = Stroke(width = strokeWidth, cap = StrokeCap.Round),
                size = Size(outerRadius * 2, outerRadius * 2),
                topLeft = Offset(center.x - outerRadius, center.y - outerRadius)
            )
            
            // 진행 원호 그리기
            val sweepAngle = totalAngle * animatedProgress.value
            drawArc(
                color = progressColor,
                startAngle = startAngle,
                sweepAngle = sweepAngle,
                useCenter = false,
                style = Stroke(width = strokeWidth, cap = StrokeCap.Round),
                size = Size(outerRadius * 2, outerRadius * 2),
                topLeft = Offset(center.x - outerRadius, center.y - outerRadius)
            )
        }
        
        // 중앙 정보 표시 - 크기 축소
        Column(
            horizontalAlignment = Alignment.CenterHorizontally,
            verticalArrangement = Arrangement.Center,
            modifier = Modifier
                .fillMaxWidth(0.6f) // 내부 요소 영역 더 축소
        ) {
            // 항목 제목
            Text(
                text = title,
                style = MaterialTheme.typography.body2,
                color = Color.White.copy(alpha = 0.7f),
                textAlign = TextAlign.Center,
                fontSize = 14.sp
            )
            
            Spacer(modifier = Modifier.height(4.dp))
            
            // 현재 수치 + 단위
            Row(
                verticalAlignment = Alignment.Bottom,
                horizontalArrangement = Arrangement.Center
            ) {
                // 현재 수치
                Text(
                    text = "$displayValue",
                    style = MaterialTheme.typography.display1.copy(
                        fontSize = 38.sp,
                        fontWeight = FontWeight.Bold
                    ),
                    color = progressColor,
                    textAlign = TextAlign.Center
                )
                
                // 단위
                Text(
                    text = unit,
                    style = MaterialTheme.typography.body1,
                    color = progressColor,
                    modifier = Modifier.padding(start = 2.dp, bottom = 6.dp),
                    fontSize = 14.sp
                )
            }
            
            // 목표 수치
            Text(
                text = "/ $targetValue$unit",
                style = MaterialTheme.typography.body2,
                color = Color.White.copy(alpha = 0.6f),
                textAlign = TextAlign.Center,
                fontSize = 12.sp
            )
            
            // 수정 가능한 항목인 경우 +/- 버튼 표시
            if (isEditable && step > 0 && onValueChange != null) {
                Spacer(modifier = Modifier.height(8.dp))
                
                // 알약 모양 버튼 - 크기 축소 및 위치 조정
                Row(
                    modifier = Modifier
                        .width(90.dp) // 버튼 폭 축소
                        .height(28.dp) // 버튼 높이 축소
                        .clip(RoundedCornerShape(50.dp))
                        .background(Color.DarkGray.copy(alpha = 0.3f))
                ) {
                    // 마이너스 버튼
                    Box(
                        modifier = Modifier
                            .weight(1f)
                            .fillMaxHeight()
                            .clip(RoundedCornerShape(topStart = 50.dp, bottomStart = 50.dp))
                            .background(if (editableValue > 0) progressColor.copy(alpha = 0.8f) else progressColor.copy(alpha = 0.3f))
                            .noRippleClickable {
                                if (editableValue > 0) {
                                    editableValue = (editableValue - step).coerceAtLeast(0)
                                    // 값 변경과 동시에 진행률 업데이트
                                    displayProgress = (editableValue.toFloat() / targetValue).coerceIn(0f, 1f)
                                    onValueChange(editableValue)
                                }
                            },
                        contentAlignment = Alignment.Center
                    ) {
                        Text(
                            text = "-",
                            fontSize = 16.sp, // 글자 크기 축소
                            fontWeight = FontWeight.Bold,
                            color = Color.White
                        )
                    }
                    
                    // 플러스 버튼
                    Box(
                        modifier = Modifier
                            .weight(1f)
                            .fillMaxHeight()
                            .clip(RoundedCornerShape(topEnd = 50.dp, bottomEnd = 50.dp))
                            .background(progressColor.copy(alpha = 0.8f))
                            .noRippleClickable {
                                editableValue += step
                                // 값 변경과 동시에 진행률 업데이트
                                displayProgress = (editableValue.toFloat() / targetValue).coerceIn(0f, 1f)
                                onValueChange(editableValue)
                            },
                        contentAlignment = Alignment.Center
                    ) {
                        Text(
                            text = "+",
                            fontSize = 16.sp, // 글자 크기 축소
                            fontWeight = FontWeight.Bold,
                            color = Color.White
                        )
                    }
                }
            }
        }
    }
}

// 시계 부분을 제외한 원호 그리기 함수
fun DrawScope.drawTimerArc(
    color: Color,
    startAngle: Float,
    sweepAngle: Float,
    useCenter: Boolean,
    radius: Float,
    strokeWidth: Float,
    excludeClockDegrees: Float = 60f  // 시계를 제외할 각도 (상단 중앙)
) {
    // 시계 부분을 제외하고 그리기 위한 각도 계산
    val excludeStartAngle = 270f - excludeClockDegrees / 2  // 시계 영역 시작 (좌측)
    val excludeEndAngle = 270f + excludeClockDegrees / 2    // 시계 영역 끝 (우측)
    
    // 전체 원을 그리는 경우 (100% 진행)
    if (sweepAngle >= 360f) {
        // 시계 영역을 제외한 좌측 부분
        drawArc(
            color = color,
            startAngle = excludeEndAngle,
            sweepAngle = (360f + excludeStartAngle - excludeEndAngle) % 360f,
            useCenter = useCenter,
            style = Stroke(width = strokeWidth, cap = StrokeCap.Round),
            size = Size(radius * 2, radius * 2),
            topLeft = Offset(center.x - radius, center.y - radius)
        )
        return
    }

    // startAngle이 제외 영역 내에 있는 경우 시작 각도 조정
    var actualStartAngle = startAngle
    if (startAngle in excludeStartAngle..excludeEndAngle) {
        actualStartAngle = excludeEndAngle
    }

    // 제외 영역을 지나는 경우, 두 부분으로 나누어 그리기
    if (startAngle < excludeStartAngle && startAngle + sweepAngle > excludeStartAngle) {
        // 첫 번째 부분: 시작 각도부터 제외 영역 시작까지
        val firstSweep = excludeStartAngle - actualStartAngle
        if (firstSweep > 0) {
            drawArc(
                color = color,
                startAngle = actualStartAngle,
                sweepAngle = firstSweep,
                useCenter = useCenter,
                style = Stroke(width = strokeWidth, cap = StrokeCap.Round),
                size = Size(radius * 2, radius * 2),
                topLeft = Offset(center.x - radius, center.y - radius)
            )
        }

        // 두 번째 부분: 제외 영역 끝부터 원래 끝 각도까지
        val remainingSweep = (startAngle + sweepAngle) - excludeEndAngle
        if (remainingSweep > 0) {
            drawArc(
                color = color,
                startAngle = excludeEndAngle,
                sweepAngle = remainingSweep,
                useCenter = useCenter,
                style = Stroke(width = strokeWidth, cap = StrokeCap.Round),
                size = Size(radius * 2, radius * 2),
                topLeft = Offset(center.x - radius, center.y - radius)
            )
        }
    } else {
        // 제외 영역을 지나지 않는 경우, 그냥 그리기
        drawArc(
            color = color,
            startAngle = actualStartAngle,
            sweepAngle = sweepAngle,
            useCenter = useCenter,
            style = Stroke(width = strokeWidth, cap = StrokeCap.Round),
            size = Size(radius * 2, radius * 2),
            topLeft = Offset(center.x - radius, center.y - radius)
        )
    }
}

// 진동 발생 함수
fun vibrate(context: Context) {
    try {
        val vibrator = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            val vibratorManager = context.getSystemService(Context.VIBRATOR_MANAGER_SERVICE) as VibratorManager
            vibratorManager.defaultVibrator
        } else {
            @Suppress("DEPRECATION")
            context.getSystemService(Context.VIBRATOR_SERVICE) as Vibrator
        }
        
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            // 안드로이드 8.0 이상에서는 VibrationEffect 사용
            vibrator.vibrate(VibrationEffect.createOneShot(300, VibrationEffect.DEFAULT_AMPLITUDE))
        } else {
            // 이전 버전에서는 deprecated 메소드 사용
            @Suppress("DEPRECATION")
            vibrator.vibrate(300)
        }
    } catch (e: Exception) {
        // 진동 기능을 사용할 수 없는 경우 무시
    }
}

// 리플 효과 없이 클릭 가능하게 하는 모디파이어 확장 함수
@Composable
fun Modifier.noRippleClickable(onClick: () -> Unit): Modifier {
    return this.then(
        Modifier.clickable(
            indication = null,
            interactionSource = remember { MutableInteractionSource() },
            onClick = onClick
        )
    )
} 