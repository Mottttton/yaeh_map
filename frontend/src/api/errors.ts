import { isAxiosError } from 'axios'

// バリデーションエラー（422 の { errors: [...] }）を取り出す。
// 想定外のエラーは fallback を返す
export function extractErrors(error: unknown, fallback: string): string[] {
  if (isAxiosError(error)) {
    const data = error.response?.data
    if (Array.isArray(data?.errors)) return data.errors
    if (typeof data?.error === 'string') return [data.error]
  }
  return [fallback]
}

// 単一メッセージ（401 の { error: "..." } など）を取り出す
export function extractErrorMessage(error: unknown, fallback: string): string {
  return extractErrors(error, fallback)[0] ?? fallback
}
