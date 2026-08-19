# GRAD PATH

성균관대학교 GLS 수강·취득 과목 PDF를 브라우저에서 분석하고, 분석이 끝나면 정규화된 결과를 Supabase에 자동 저장하는 웹 앱입니다. PDF 원본은 Supabase로 전송하지 않습니다.

학생 이름 원문은 저장하지 않고 가운데 글자를 `*`로 가린 이름만 기록합니다(예: `설석환` → `설*환`, `박건` → `박*`). 분석 테이블에는 입학년도(`entry_year`), PDF의 이수·등록 학기 수로 계산한 학년(`academic_year`), 수강 중 학점(`enrolled_credits`)을 별도 열로 저장합니다. 학기를 확인하지 못한 경우 학년은 `null`로 남깁니다.

## Supabase 설정

1. Supabase 대시보드의 SQL Editor에서 [`supabase/schema.sql`](supabase/schema.sql)을 실행합니다.
2. Authentication의 Anonymous Sign-Ins를 활성화합니다.
3. Vercel 프로젝트의 Settings → Environment Variables에 다음 값을 추가합니다.

   - `SUPABASE_URL`: Supabase Project URL
   - `SUPABASE_ANON_KEY`: anon key 또는 publishable key

4. Production, Preview, Development 환경을 선택하고 Vercel에서 재배포합니다.

`service_role` 또는 secret key는 Vercel 환경변수와 이 저장소 어디에도 넣지 않습니다. 브라우저에는 `/api/config`를 통해 공개 가능한 URL과 anon/publishable key만 전달됩니다. 데이터 접근은 `supabase/schema.sql`의 RLS 정책으로 현재 익명 로그인 세션 소유자에게만 허용됩니다.

로컬에서 HTML 파일을 직접 열면 분석 기능은 사용할 수 있지만 Supabase 저장 기능은 비활성화됩니다. 저장 기능까지 시험하려면 Vercel 배포 주소에서 실행하세요.
