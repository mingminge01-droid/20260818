# GRAD PATH

성균관대학교 GLS 수강·취득 과목 PDF를 브라우저에서 분석하고, 사용자가 선택한 경우 정규화된 분석 결과만 Supabase에 저장하는 웹 앱입니다. PDF 원본은 Supabase로 전송하지 않습니다.

## Supabase 설정

1. Supabase 대시보드의 SQL Editor에서 [`supabase/schema.sql`](supabase/schema.sql)을 실행합니다.
2. Authentication의 Anonymous Sign-Ins를 활성화합니다.
3. Vercel 프로젝트의 Settings → Environment Variables에 다음 값을 추가합니다.

   - `SUPABASE_URL`: Supabase Project URL
   - `SUPABASE_ANON_KEY`: anon key 또는 publishable key

4. Production, Preview, Development 환경을 선택하고 Vercel에서 재배포합니다.

`service_role` 또는 secret key는 Vercel 환경변수와 이 저장소 어디에도 넣지 않습니다. 브라우저에는 `/api/config`를 통해 공개 가능한 URL과 anon/publishable key만 전달됩니다. 데이터 접근은 `supabase/schema.sql`의 RLS 정책으로 현재 익명 로그인 세션 소유자에게만 허용됩니다.

로컬에서 HTML 파일을 직접 열면 분석 기능은 사용할 수 있지만 Supabase 저장 기능은 비활성화됩니다. 저장 기능까지 시험하려면 Vercel 배포 주소에서 실행하세요.
