# slide_renamer.py
import os
import re
import tkinter as tk
from tkinter import filedialog, messagebox, ttk

# ─── 자연어 정렬 키 ───────────────────────────────────────────
def natural_sort_key(filename):
    name = os.path.splitext(filename)[0]
    parts = re.split(r'(\d+)', name)
    return [int(p) if p.isdigit() else p.lower() for p in parts]

# ─── 메인 앱 ─────────────────────────────────────────────────
class SlideRenamer(tk.Tk):
    def __init__(self):
        super().__init__()
        self.title("슬라이드 Rename 도구")
        self.geometry("720x600")
        self.resizable(False, False)
        self.configure(bg="#1e1e2e")

        self.selected_files = []  # 선택된 파일 전체 경로 리스트
        self.file_pairs     = []  # [(원본 전체경로, 새 전체경로), ...]

        self._build_ui()

    # ── UI 구성 ──────────────────────────────────────────────
    def _build_ui(self):
        PAD = dict(padx=16, pady=6)

        # ① 타이틀
        tk.Label(self, text="🎞 슬라이드 Rename 도구",
                 bg="#1e1e2e", fg="#cdd6f4",
                 font=("맑은 고딕", 16, "bold")).pack(pady=(18, 2))

        tk.Label(self, text="원하는 .html 파일만 선택 → 자동 재정렬 (01 / 02 / 03 ...)",
                 bg="#1e1e2e", fg="#a6adc8",
                 font=("맑은 고딕", 10)).pack()

        # ② 파일 선택 버튼 + 선택 초기화 버튼
        frame_btn = tk.Frame(self, bg="#1e1e2e")
        frame_btn.pack(fill="x", **PAD)

        tk.Button(frame_btn, text="📄 파일 선택 (중복 선택 가능)",
                  bg="#89b4fa", fg="#1e1e2e",
                  font=("맑은 고딕", 11, "bold"),
                  relief="flat", cursor="hand2",
                  command=self._select_files
                  ).pack(side="left", ipady=7, ipadx=12)

        tk.Button(frame_btn, text="🗑 선택 초기화",
                  bg="#45475a", fg="#cdd6f4",
                  font=("맑은 고딕", 10),
                  relief="flat", cursor="hand2",
                  command=self._clear_selection
                  ).pack(side="left", ipady=7, ipadx=10, padx=(8, 0))

        # ③ 선택된 파일 수 표시
        self.count_var = tk.StringVar(value="선택된 파일: 0개")
        tk.Label(self, textvariable=self.count_var,
                 bg="#1e1e2e", fg="#fab387",
                 font=("맑은 고딕", 10)).pack(anchor="w", padx=16, pady=(0, 2))

        # ④ 미리보기 테이블
        tk.Label(self, text="변경 미리보기",
                 bg="#1e1e2e", fg="#a6adc8",
                 font=("맑은 고딕", 10)).pack(anchor="w", padx=16)

        frame_tree = tk.Frame(self, bg="#1e1e2e")
        frame_tree.pack(fill="both", expand=True, padx=16, pady=4)

        style = ttk.Style()
        style.theme_use("clam")
        style.configure("Custom.Treeview",
                        background="#313244",
                        foreground="#cdd6f4",
                        fieldbackground="#313244",
                        rowheight=28,
                        font=("맑은 고딕", 10))
        style.configure("Custom.Treeview.Heading",
                        background="#45475a",
                        foreground="#cdd6f4",
                        font=("맑은 고딕", 10, "bold"))
        style.map("Custom.Treeview",
                  background=[("selected", "#89b4fa")],
                  foreground=[("selected", "#1e1e2e")])

        self.tree = ttk.Treeview(frame_tree,
                                 columns=("before", "arrow", "after"),
                                 show="headings",
                                 style="Custom.Treeview")
        self.tree.heading("before", text="현재 파일명")
        self.tree.heading("arrow",  text="")
        self.tree.heading("after",  text="변경될 파일명")
        self.tree.column("before", width=270, anchor="center")
        self.tree.column("arrow",  width=60,  anchor="center")
        self.tree.column("after",  width=270, anchor="center")

        scrollbar = ttk.Scrollbar(frame_tree, orient="vertical",
                                  command=self.tree.yview)
        self.tree.configure(yscrollcommand=scrollbar.set)
        self.tree.pack(side="left", fill="both", expand=True)
        scrollbar.pack(side="right", fill="y")

        # ⑤ 상태 메시지
        self.status_var = tk.StringVar(value="파일을 선택하면 미리보기가 표시됩니다.")
        tk.Label(self, textvariable=self.status_var,
                 bg="#1e1e2e", fg="#a6e3a1",
                 font=("맑은 고딕", 10)).pack(pady=4)

        # ⑥ Rename 실행 버튼
        self.btn_rename = tk.Button(
            self, text="✅  지금 바로 Rename 실행",
            bg="#a6e3a1", fg="#1e1e2e",
            font=("맑은 고딕", 12, "bold"),
            relief="flat", cursor="hand2",
            state="disabled",
            command=self._do_rename
        )
        self.btn_rename.pack(pady=(4, 18), ipadx=20, ipady=8)

    # ── 파일 선택 ────────────────────────────────────────────
    def _select_files(self):
        files = filedialog.askopenfilenames(
            title="rename할 슬라이드 파일 선택 (Ctrl/Shift로 중복 선택)",
            filetypes=[("HTML 파일", "*.html"), ("모든 파일", "*.*")]
        )
        if not files:
            return

        # 기존 선택에 새 파일 추가 (중복 제거)
        existing = set(self.selected_files)
        for f in files:
            if f not in existing:
                self.selected_files.append(f)
                existing.add(f)

        self._load_preview()

    # ── 선택 초기화 ──────────────────────────────────────────
    def _clear_selection(self):
        self.selected_files.clear()
        self.file_pairs.clear()
        for row in self.tree.get_children():
            self.tree.delete(row)
        self.count_var.set("선택된 파일: 0개")
        self.status_var.set("파일을 선택하면 미리보기가 표시됩니다.")
        self.btn_rename.config(state="disabled")

    # ── 미리보기 로드 ────────────────────────────────────────
    def _load_preview(self):
        for row in self.tree.get_children():
            self.tree.delete(row)
        self.file_pairs.clear()

        if not self.selected_files:
            return

        # 같은 폴더 여부 검사
        folders = set(os.path.dirname(f) for f in self.selected_files)
        if len(folders) > 1:
            self.status_var.set("⚠️  서로 다른 폴더의 파일이 섞여 있습니다. 같은 폴더 파일만 선택하세요.")
            self.btn_rename.config(state="disabled")
            return

        # 자연어 정렬
        sorted_files = sorted(self.selected_files, key=lambda f: natural_sort_key(os.path.basename(f)))

        self.count_var.set(f"선택된 파일: {len(sorted_files)}개")

        changed_count = 0
        for i, old_path in enumerate(sorted_files):
            old_name = os.path.basename(old_path)
            new_name = f"{i + 1:02d}.html"
            folder   = os.path.dirname(old_path)
            new_path = os.path.join(folder, new_name)

            tag = "same"
            if old_name != new_name:
                tag = "changed"
                changed_count += 1

            self.tree.insert("", "end",
                             values=(old_name, "→", new_name),
                             tags=(tag,))
            self.file_pairs.append((old_path, new_path))

        self.tree.tag_configure("changed", foreground="#f38ba8")
        self.tree.tag_configure("same",    foreground="#a6adc8")

        if changed_count == 0:
            self.status_var.set("✅  이미 모든 파일이 올바른 순서입니다. 변경 불필요!")
            self.btn_rename.config(state="disabled")
        else:
            self.status_var.set(
                f"📋  총 {len(sorted_files)}개 파일 중 {changed_count}개 변경 예정  "
                f"(🔴 빨간색 = 변경 대상)"
            )
            self.btn_rename.config(state="normal")

    # ── 실제 Rename 실행 ─────────────────────────────────────
    def _do_rename(self):
        folder = os.path.dirname(self.file_pairs[0][0])

        confirm = messagebox.askyesno(
            "Rename 확인",
            f"총 {len(self.file_pairs)}개 파일을 rename 하시겠습니까?\n\n"
            f"📂 폴더: {folder}\n\n"
            "⚠️ 이 작업은 되돌릴 수 없습니다."
        )
        if not confirm:
            return

        try:
            # 1단계: 임시 이름으로 변경 (충돌 방지)
            tmp_paths = []
            for i, (old_path, _) in enumerate(self.file_pairs):
                tmp_path = os.path.join(os.path.dirname(old_path), f"__tmp_{i:04d}.html")
                os.rename(old_path, tmp_path)
                tmp_paths.append(tmp_path)

            # 2단계: 최종 이름으로 변경
            for tmp_path, (_, new_path) in zip(tmp_paths, self.file_pairs):
                os.rename(tmp_path, new_path)

            messagebox.showinfo(
                "완료 ✅",
                f"{len(self.file_pairs)}개 파일 rename 완료!\n\n"
                f"📂 {folder}"
            )

            # 완료 후 초기화
            self._clear_selection()

        except Exception as e:
            messagebox.showerror("오류 ❌", f"rename 중 오류 발생:\n{e}")

# ─── 실행 진입점 ──────────────────────────────────────────────
if __name__ == "__main__":
    app = SlideRenamer()
    app.mainloop()
