-- ═══════════════════════════════════════════════════════
-- Spark — Seed: NCERT Maths Class 9
-- Chapters: Number Systems, Polynomials
-- Run in Supabase SQL Editor (safe to re-run)
-- ═══════════════════════════════════════════════════════

DO $$
DECLARE
  v_subject_id  uuid;
  v_ns_id       uuid;   -- Number Systems topic_id
  v_poly_id     uuid;   -- Polynomials topic_id

  v_ns_body     text := $ns$Riya''s family just moved into a new flat. Her father hands her a measuring tape: "Mark the ropes we need."

The window is exactly 3 metres. Clean. She writes it as 3/1. Any measurement expressible as one integer over another — 1/2, 7/4, 0.333… — is a rational number. Predictable. Tidy.

Then comes the tricky one. A square tile, 1m × 1m. She measures its diagonal: 1.41421356… The digits never end, never repeat. She tries writing it as a fraction. She can''t. Nobody can. This is √2 — an irrational number. It''s physically there, stretched across the tile, but it refuses to be tamed into p/q.

Now imagine every rope ever cut — 3m, 1/2m, √2m, πm — laid out on a single line. Every rational, every irrational, no gaps. That line is the Real Numbers.

Rational numbers are the ropes you can order from a catalogue. Irrational numbers are what reality hands you when you measure diagonals. Real numbers are the drawer that holds them all.$ns$;

  v_poly_body   text := $poly$It''s lunch break. Meera throws a ball straight up and shouts: "How high does it go? When does it land?"

Her friend Kabir writes a rule for its height: height = −5t² + 20t. One letter (t = seconds). A few terms. You put time in, you get height out. That''s a polynomial — nothing more than a rule with one variable.

Meera wants to know when the ball hits the ground: height = 0. They get −5t(t − 4) = 0. Either t = 0 (when she threw it) or t = 4 (when it lands). Those two answers are the zeroes of the polynomial.

Kabir asks: "What''s the height at t = 3?" Meera just puts 3 into the rule: −5(9) + 20(3) = 15. Done in one step. That shortcut — just plug it in — is the Remainder Theorem.

Can they break −5t² + 20t into simpler pieces? They try −5t and (t − 4). Multiply them: exact match, no leftovers. When something divides with zero remainder, it''s a factor — that''s the Factor Theorem.

The PE teacher asks: "What''s (t + 4)²?" Meera writes instantly: t² + 8t + 16. No working needed — she knows the pattern. These ready-made shortcuts are algebraic identities.

A polynomial is a rule for one variable. Zeroes are when the output hits zero. The Remainder Theorem says: just plug in. The Factor Theorem says: zero output means it divides cleanly. Identities are patterns you memorise so you skip the working.$poly$;

BEGIN

-- ──────────────────────────────────────────
-- SUBJECT
-- ──────────────────────────────────────────

  SELECT subject_id INTO v_subject_id
  FROM subjects WHERE name = 'Mathematics' LIMIT 1;

  IF v_subject_id IS NULL THEN
    INSERT INTO subjects (name, name_hi, icon, color_hex, board_alignment, is_free_preview, sort_order, is_active)
    VALUES ('Mathematics', 'गणित', '📐', '#0EA5A0', 'CBSE', true, 1, true)
    RETURNING subject_id INTO v_subject_id;
    RAISE NOTICE 'Created subject: %', v_subject_id;
  ELSE
    RAISE NOTICE 'Subject exists: %', v_subject_id;
  END IF;

-- ──────────────────────────────────────────
-- TOPIC 1: Number Systems
-- ──────────────────────────────────────────

  SELECT topic_id INTO v_ns_id
  FROM topics WHERE subject_id = v_subject_id AND name = 'Number Systems' LIMIT 1;

  IF v_ns_id IS NULL THEN
    INSERT INTO topics (subject_id, name, name_hi, grade, sort_order, is_active)
    VALUES (v_subject_id, 'Number Systems', 'संख्या पद्धति', '9', 1, true)
    RETURNING topic_id INTO v_ns_id;
    RAISE NOTICE 'Created topic Number Systems: %', v_ns_id;
  ELSE
    RAISE NOTICE 'Topic Number Systems exists: %', v_ns_id;
  END IF;

  -- Story
  INSERT INTO topic_content (topic_id, lang, title, body, version)
  VALUES (v_ns_id, 'en', 'The Day Riya Measured the World', v_ns_body, 1)
  ON CONFLICT (topic_id, lang, version) DO UPDATE SET title = EXCLUDED.title, body = EXCLUDED.body;

  -- Real World Apps
  DELETE FROM real_world_apps WHERE topic_id = v_ns_id;
  INSERT INTO real_world_apps (topic_id, icon, bg_color, title, description, sort_order) VALUES
    (v_ns_id, '📱', '#E0F2FE', 'The UPI Transaction You Do Every Day',
     'Every time you pay ₹47.50 via UPI, the app processes it as a rational number (4750/100). But bank interest overnight is almost never clean — stored as a real number, rounded only for display. Sub-topic: Rational numbers, operations on real numbers.',
     0),
    (v_ns_id, '🪪', '#FEF3C7', 'Why Your Aadhaar Card Exists',
     'India stores biometric data for 1.4 billion people. Storage is calculated using powers of 2. One fingerprint ≈ 2¹⁰ bytes. 1.4 billion × 10 fingers = 1.4 × 10¹⁰ fingerprints. Sub-topic: Laws of exponents, scientific notation.',
     1),
    (v_ns_id, '🛺', '#D1FAE5', 'The Rickshaw Driver Who Uses Irrational Numbers',
     'An auto driver''s diagonal shortcut across a colony is always √(l² + b²). For 300m × 500m that is ≈ 583.09…m — irrational. He saves time using a number he can''t write as a fraction. Sub-topic: Irrational numbers, real numbers, operations.',
     2),
    (v_ns_id, '🏏', '#EDE9FE', 'Cricket DLS Method',
     'When rain stops a match, the Duckworth-Lewis-Stern revised target uses exponential functions. That "India need 47 off 5 overs" moment came from exponent-based real number math. Sub-topic: Laws of exponents, real numbers in applied context.',
     3),
    (v_ns_id, '📺', '#FCE7F3', 'The Screen You''re Reading This On',
     'A 6.5-inch 16:9 screen diagonal = √(16² + 9²) × k — an irrational number. Phone manufacturers can''t avoid irrationals when designing displays. Every screen size is technically irrational, rounded for marketing. Sub-topic: Irrational numbers, number line representation.',
     4);

  -- Profession Voices
  DELETE FROM topic_profession_voices WHERE topic_id = v_ns_id;
  INSERT INTO topic_profession_voices (topic_id, profession_title, quote_text, subtopic_link, sort_order) VALUES
    (v_ns_id, 'Civil Engineer',
     'Every day I work with numbers that aren''t clean or whole. When I design a staircase or a ramp, I calculate the diagonal length — and almost always the answer is an irrational number like √5 or √13. If I round off too early, the structure shifts by millimetres — and over a 10-storey building, that millimetre becomes centimetres by the top floor. The number line I studied in Class 9 is something I use every single day — except now, mistakes cost crores.',
     'Irrational numbers, real numbers, operations on real numbers', 0),
    (v_ns_id, 'Data Scientist / AI Engineer',
     'My job is to teach computers to make decisions. Every piece of data I feed a machine learning model is a real number. The model''s output is a probability, always a real number between 0 and 1. When I train a model, I use exponent-based math thousands of times per second. I remember being confused about laws of exponents in school. Now I can''t do a single day''s work without them.',
     'Laws of exponents, real numbers, operations', 1),
    (v_ns_id, 'Chartered Accountant (CA)',
     'People think accounting is just addition and subtraction. It isn''t. When I calculate compound interest or depreciate an asset over 7 years, the numbers are never whole numbers. They''re rational decimals at best, and sometimes they don''t terminate at all. The entire real number line, positive and negative, is my workspace. The foundation of everything I do professionally was laid in one chapter of Class 9 Maths.',
     'Rational numbers, operations on real numbers', 2),
    (v_ns_id, 'ISRO / Space Scientist',
     'When we planned Chandrayaan-3''s lunar orbit insertion, we calculated distances in hundreds of thousands of kilometres — numbers so large we can only write them using powers of 10. A spacecraft travelling at 1.6 km/s needs fuel burn corrections to 5 decimal places. The moon is 384,400 km away — if our exponent calculation is off by even one power, we miss it entirely.',
     'Laws of exponents, scientific notation, real numbers', 3);

-- ──────────────────────────────────────────
-- TOPIC 2: Polynomials
-- ──────────────────────────────────────────

  SELECT topic_id INTO v_poly_id
  FROM topics WHERE subject_id = v_subject_id AND name = 'Polynomials' LIMIT 1;

  IF v_poly_id IS NULL THEN
    INSERT INTO topics (subject_id, name, name_hi, grade, sort_order, is_active)
    VALUES (v_subject_id, 'Polynomials', 'बहुपद', '9', 2, true)
    RETURNING topic_id INTO v_poly_id;
    RAISE NOTICE 'Created topic Polynomials: %', v_poly_id;
  ELSE
    RAISE NOTICE 'Topic Polynomials exists: %', v_poly_id;
  END IF;

  -- Story
  INSERT INTO topic_content (topic_id, lang, title, body, version)
  VALUES (v_poly_id, 'en', 'The Day Meera Threw a Ball', v_poly_body, 1)
  ON CONFLICT (topic_id, lang, version) DO UPDATE SET title = EXCLUDED.title, body = EXCLUDED.body;

  -- Real World Apps
  DELETE FROM real_world_apps WHERE topic_id = v_poly_id;
  INSERT INTO real_world_apps (topic_id, icon, bg_color, title, description, sort_order) VALUES
    (v_poly_id, '🎮', '#EDE9FE', 'The Jump in Every Video Game You''ve Played',
     'In BGMI, FIFA, any game — a jump arc is a quadratic polynomial: h(t) = -5t² + v₀t. The game engine solves for its zeroes 60 times per second to trigger the landing animation. Sub-topic: Zeroes of a polynomial, polynomials in one variable.',
     0),
    (v_poly_id, '💬', '#D1FAE5', 'Why Your WhatsApp Message Arrives Uncorrupted',
     'Reed-Solomon error correction — used in every 4G/5G network — encodes data as a polynomial and checks the remainder at the receiving end. Remainder = 0 means the message is clean. That''s the Remainder Theorem. Sub-topic: Remainder theorem, factor theorem.',
     1),
    (v_poly_id, '🏛️', '#FEF3C7', 'The Hidden Polynomial in Every Metro Arch',
     'Metro arches in Delhi, Mumbai, and Bengaluru follow y = ax² + bx + c. The two feet of the arch are the zeroes. Engineers use the Factor Theorem to find them and place foundations correctly. Sub-topic: Zeroes of a polynomial, factor theorem, algebraic identities.',
     2),
    (v_poly_id, '🛒', '#FCE7F3', 'The Algebra Behind Every Amazon Sale Price',
     'E-commerce pricing models use polynomial regression to find break-even points — zeroes of the profit polynomial. The identity (a+b)² = a² + 2ab + b² appears constantly when expanding error terms in these models. Sub-topic: Algebraic identities, zeroes of a polynomial.',
     3),
    (v_poly_id, '🎬', '#E0F2FE', 'How Animators at Indian VFX Studios Draw Smooth Curves',
     'Every smooth Bollywood VFX curve is a Bézier polynomial of degree 2, 3, or higher. Control points are the coefficients. Splitting a curve at a point uses the Remainder Theorem applied to polynomial division. Sub-topic: Polynomials in one variable, remainder theorem, factor theorem.',
     4);

  -- Profession Voices
  DELETE FROM topic_profession_voices WHERE topic_id = v_poly_id;
  INSERT INTO topic_profession_voices (topic_id, profession_title, quote_text, subtopic_link, sort_order) VALUES
    (v_poly_id, 'Software Engineer / Game Developer',
     'In game development, when a character jumps — the arc is a polynomial. Specifically a quadratic: h(t) = -5t² + 10t. I need to find when the character lands, which means finding the zeroes of that polynomial. In my first job at a Pune gaming studio, I realised the Factor Theorem from Class 9 was the exact tool I needed to factorise physics equations and make characters move smoothly. I use it every sprint.',
     'Zeroes of a polynomial, factor theorem, polynomials in one variable', 0),
    (v_poly_id, 'Civil / Structural Engineer',
     'The graceful curve of a flyover or a suspension bridge is not drawn freehand — it''s a polynomial. A parabolic arch follows y = ax² + bx + c. The two points where the arch meets the ground are the zeroes. I calculate those zeroes to decide where to place foundations. If I get that wrong, the arch carries unequal loads and risks cracking.',
     'Zeroes of a polynomial, factor theorem, remainder theorem', 1),
    (v_poly_id, 'Telecom Engineer (4G/5G Networks)',
     'When your phone sends a message, errors creep in during transmission. We fix this using Reed-Solomon error correction, which is built entirely on polynomial arithmetic. We check the remainder when dividing the received polynomial by known factors. If remainder = zero, the message is perfect. The Remainder Theorem is literally the mathematical heart of 4G and 5G communication.',
     'Remainder theorem, factor theorem, polynomials in one variable', 2),
    (v_poly_id, 'Data Scientist / Business Analyst',
     'When I model how sales grow over a quarter, a straight line is almost never enough. I fit a degree-2 or degree-3 polynomial to the data — polynomial regression. The zeroes tell me break-even points. The algebraic identities I memorised in school — (a+b)², (a-b)², (a+b)(a-b) — are my fastest tool for expanding expressions under deadline pressure.',
     'Algebraic identities, zeroes of a polynomial, polynomials in one variable', 3);

  RAISE NOTICE 'Seed complete.';
END $$;
