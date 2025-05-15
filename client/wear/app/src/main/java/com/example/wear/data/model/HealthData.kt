package com.example.wear.data.model

/**
 * 헬스 데이터 모델 클래스
 */
data class HealthData(
    // 현재 데이터
    val steps: Int = 0,
    val calories: Int = 0,
    val water: Int = 0,
    val caffeine: Int = 0,
    
    // 목표 데이터
    val stepsGoal: Int = 10000,
    val caloriesGoal: Int = 2000,
    val waterGoal: Int = 2000,
    val caffeineGoal: Int = 400
) {
    // 진행률 계산 함수들
    fun getStepsProgress(): Float = (steps.toFloat() / stepsGoal).coerceIn(0f, 1f)
    fun getCaloriesProgress(): Float = (calories.toFloat() / caloriesGoal).coerceIn(0f, 1f)
    fun getWaterProgress(): Float = (water.toFloat() / waterGoal).coerceIn(0f, 1f)
    fun getCaffeineProgress(): Float = (caffeine.toFloat() / caffeineGoal).coerceIn(0f, 1f)
    
    // 서식이 지정된 문자열 반환
    fun getStepsFormatted(): String = "$steps / ${stepsGoal}걸음"
    fun getCaloriesFormatted(): String = "$calories / ${caloriesGoal}kcal"
    fun getWaterFormatted(): String = "$water / ${waterGoal}ml"
    fun getCaffeineFormatted(): String = "$caffeine / ${caffeineGoal}mg"
} 