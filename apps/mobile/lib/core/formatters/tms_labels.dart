String localizeUserRole(String role) {
  switch (role.toUpperCase()) {
    case 'SUPER_ADMIN':
      return '슈퍼 관리자';
    case 'ADMIN':
      return '관리자';
    case 'DISPATCHER':
      return '배차 담당';
    case 'OPS':
      return '운영 담당';
    case 'DRIVER':
      return '기사';
    case 'CS':
      return '고객 지원';
    case 'ACCOUNTING':
      return '정산 담당';
    case 'CUSTOMER':
      return '고객사';
    default:
      return role;
  }
}

String localizeStatus(String status) {
  switch (status.toUpperCase()) {
    case 'REQUESTED':
      return '요청 접수';
    case 'CONFIRMED':
      return '확정';
    case 'DISPATCHING':
      return '배차 중';
    case 'DISPATCHED':
      return '배차 완료';
    case 'PICKUP_COMPLETED':
      return '상차 완료';
    case 'IN_TRANSIT':
      return '운송 중';
    case 'DELIVERED':
      return '배송 완료';
    case 'COMPLETED':
      return '완료';
    case 'CANCELLED':
      return '취소';
    case 'ASSIGNED':
      return '배정';
    case 'ACCEPTED':
      return '수락';
    case 'REJECTED':
      return '거절';
    case 'ENROUTE_PICKUP':
      return '상차지 이동';
    case 'AT_PICKUP':
      return '상차지 도착';
    case 'LOADED':
      return '상차 완료';
    case 'AT_DELIVERY':
      return '하차지 도착';
    case 'POD_UPLOADED':
      return '인수증 업로드';
    case 'PENDING':
      return '대기';
    case 'CALCULATED':
      return '계산 완료';
    case 'INVOICED':
      return '청구 완료';
    case 'PARTIALLY_PAID':
      return '부분 수금';
    case 'PAID':
      return '수금 완료';
    default:
      return status;
  }
}

String localizeErrorMessage(Object error) {
  final message = error.toString().replaceFirst('Exception: ', '');
  final loginFailed = RegExp(r'Login failed \((\d+)\)').firstMatch(message);
  if (loginFailed != null) {
    return '로그인에 실패했습니다. (${loginFailed.group(1)})';
  }
  if (message.contains('Failed to fetch')) {
    return 'API 서버에 연결하지 못했습니다. 주소와 브라우저 접근 설정을 확인해 주세요.';
  }
  if (message.contains('Connection refused')) {
    return 'API 서버 연결이 거부되었습니다. 서버가 실행 중인지 확인해 주세요.';
  }
  if (message.contains('timed out')) {
    return '서버 응답 시간이 초과되었습니다.';
  }
  return message;
}

String formatCompactKrw(double value) {
  final prefix = value < 0 ? '-' : '';
  final absolute = value.abs();
  if (absolute >= 100000000) {
    return '$prefix${(absolute / 100000000).toStringAsFixed(1)}억 원';
  }
  if (absolute >= 10000) {
    return '$prefix${(absolute / 10000).toStringAsFixed(0)}만 원';
  }
  return '$prefix${absolute.toStringAsFixed(0)}원';
}

String formatKoreanDate(DateTime value) {
  final month = value.month.toString().padLeft(2, '0');
  final day = value.day.toString().padLeft(2, '0');
  return '${value.year}.$month.$day';
}

String formatKoreanDateTime(DateTime value) {
  final hour = value.hour.toString().padLeft(2, '0');
  final minute = value.minute.toString().padLeft(2, '0');
  return '${value.month}월 ${value.day}일 $hour:$minute';
}
