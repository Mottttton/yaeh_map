// 旧 Rails の time_ago_in_words（ja ロケール）相当の簡易実装
export function timeAgoInWords(iso) {
  const seconds = Math.floor((Date.now() - new Date(iso).getTime()) / 1000)
  if (seconds < 60) return `${Math.max(seconds, 1)}秒前`
  const minutes = Math.floor(seconds / 60)
  if (minutes < 60) return `${minutes}分前`
  const hours = Math.floor(minutes / 60)
  if (hours < 24) return `約${hours}時間前`
  const days = Math.floor(hours / 24)
  if (days < 30) return `${days}日前`
  const months = Math.floor(days / 30)
  if (months < 12) return `${months}ヶ月前`
  const years = Math.floor(days / 365)
  return `約${Math.max(years, 1)}年前`
}
