# فانتزي شرم الشيخ

ويب أب فانتزي كورة (زي Fantasy Premier League) — اللاعيبة = حسابات ناس حقيقية بتسجّل، والأدمن يعتمدهم.

## الملفات

| ملف | وظيفة |
|-----|--------|
| `index.html` | التطبيق كامل (فريق / سوق / ترتيب / حساب / أدمن) |
| `config.example.js` | مثال إعدادات Supabase |
| `config.js` | مفاتيحك (مش على Git — اعمله محليًا) |
| `supabase/schema.sql` | الجداول + RLS + 5 لاعيبة ديمو |

## الحالة الحالية

- GitHub: https://github.com/acephonics/fantasy-sharm
- Supabase project: `fantasy-sharm` (`pjhbhouykdcprjegdfvf`)
- Schema + RLS + 5 لاعيبة ديمو: شغال
- Confirm email: مقفول (تسجيل مباشر)
- `config.js` محلي ومتجاهل من Git

## 1) تشغيل الموقع محليًا

افتح الملف:

`C:\Users\RC\OneDrive\Desktop\fantasy-sharm\index.html`

(أو Live Server من VS Code/Cursor)

## 2) عمل حساب أدمن (مرة واحدة)

1. من التطبيق: **حساب جديد** بإيميلك
2. تبويب **حسابي** → احفظ اسمك
3. في Supabase → SQL Editor:

```sql
update public.players
set is_admin = true, approved = true
where user_id = (select id from auth.users where email = 'YOUR_EMAIL@example.com');
```

4. Refresh → هيظهر تبويب **أدمن**

## 3) عمل حساب أدمن (full access)

1. من التطبيق: **حساب جديد** بإيميلك
2. من تبويب **حسابي**: احفظ اسمك كلاعب
3. في Supabase → SQL Editor:

```sql
update public.players
set is_admin = true, approved = true
where user_id = (select id from auth.users where email = 'YOUR_EMAIL@example.com');
```

4. اعمل Refresh للصفحة → هيبان تبويب **أدمن**

### صلاحيات الأدمن

- اعتماد / إلغاء اعتماد اللاعيبة
- تعديل التقييم والنقاط والمركز
- حذف لاعب
- ترقية أدمن تاني
- تسمية الجولة + قفل التحويلات
- إعادة حساب نقاط كل الفرق
- مشاهدة كل الفرق

## 4) الـ 5 لاعيبة ديمو

بعد تشغيل `schema.sql` هتلاقي 5 لاعيبة معتمدين جاهزين في السوق (من غير حساب دخول). أي حد جديد يسجّل يظهر بعد اعتماد الأدمن.

## 5) رفع على GitHub

المستودع جاهز للدفع. `config.js` متجاهل في `.gitignore` عشان المفاتيح متترفعش.

## 6) نشر Live (بعد الربط)

- **Netlify / Cloudflare Pages / GitHub Pages**: ارفع الفولدر (وضيف `config.js` في إعدادات الاستضافة أو Environment لو حوّلت لبناء)
- أبسط طريقة سريعة: ارفع `index.html` + `config.js` على Netlify Drag & Drop

## قواعد الفريق

- 15 لاعب · ميزانية £100M · أقصى 3 من نفس النادي
- تشكيل 4-4-2 · كابتن ×2
