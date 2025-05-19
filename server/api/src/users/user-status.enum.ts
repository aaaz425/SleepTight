
export enum UserStatus {
    INCOMPLETE_REGISTRATION = 'incomplete_registration', //임시 가입 회원
    ACTIVE = 'active', // 활성화 회원
    DORMANT = 'dormant', //휴면 회원
    PENDING_WITHDRAW = 'pending_withdraw', //탈퇴 유예 회원(90일 후 가명화 후 탈퇴회원으로 전환)
    WITHDRAWN = 'withdrawn',//탈퇴 회원
}