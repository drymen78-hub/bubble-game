# index.html 에서 실제 렌더링되는 모든 글자를 추출해 Jua/Nunito 폰트를 서브셋한다.
# 결과: fonts/Jua-subset.woff2, fonts/Nunito-subset.woff2 (자체 호스팅용)
import os, subprocess, sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
html = open(os.path.join(ROOT, 'index.html'), encoding='utf-8').read()

# index.html 안의 모든 문자(UI 문구·단어 데이터·공유 템플릿 전부 포함) = 렌더링 가능한 상한집합
chars = set(html)
# 기본 ASCII·라틴 보충(악센트: León, José 등) 보강
for cp in list(range(0x20, 0x7F)) + list(range(0xA1, 0x100)):
    chars.add(chr(cp))
# 제어문자 제거
chars = {c for c in chars if ord(c) >= 0x20}

charset_path = os.path.join(ROOT, 'tools', '_fontsrc', 'charset.txt')
open(charset_path, 'w', encoding='utf-8').write(''.join(sorted(chars)))
print(f'추출된 고유 글자 수: {len(chars)}')

def subset(src, out, extra=None):
    args = [sys.executable, '-m', 'fontTools.subset', src,
            f'--text-file={charset_path}',
            '--flavor=woff2',
            f'--output-file={out}',
            '--no-hinting', '--desubroutinize',
            '--layout-features=*', '--glyph-names']
    if extra:
        args += extra
    subprocess.run(args, check=True)
    print(f'  {os.path.basename(out)}: {os.path.getsize(out)//1024} KB')

src_dir = os.path.join(ROOT, 'tools', '_fontsrc')
out_dir = os.path.join(ROOT, 'fonts')
os.makedirs(out_dir, exist_ok=True)

print('Jua 서브셋...')
subset(os.path.join(src_dir, 'Jua-Regular.ttf'), os.path.join(out_dir, 'Jua-subset.woff2'))
print('Nunito 서브셋(가변축 유지)...')
# 가변 폰트: wght 축 유지(700~900 사용)
subset(os.path.join(src_dir, 'Nunito.ttf'), os.path.join(out_dir, 'Nunito-subset.woff2'))
print('완료')
