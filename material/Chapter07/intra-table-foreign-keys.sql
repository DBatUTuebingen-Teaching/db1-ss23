-- Demonstrate the use of intra-table foreign keys
\c scratch

-- Rooted, labelled tree

DROP TABLE IF EXISTS tree CASCADE;

DROP DOMAIN IF EXISTS label;
CREATE DOMAIN label AS char(1);

CREATE TABLE tree (
  node   label,
  parent label
);

ALTER TABLE tree
  ADD PRIMARY KEY (node);

-- Establish foreign-key constraint to ensure that nodes
-- properly point to parent nodes

-- ⚠️ Either use compensation actions based
--    - Option 1 (ON DELETE SET NULL) or
--    - Option 2 (ON DELETE CASCADE)
--    but not both.

-- Option 1: ON DELETE SET NULL (resulting semantics?)
ALTER TABLE tree
  ADD FOREIGN KEY (parent) REFERENCES tree
  ON DELETE SET NULL;

-- Option 2: ON DELETE CASCADE (resulting semantics?)
-- ALTER TABLE tree
--   ADD FOREIGN KEY (parent) REFERENCES tree
--   ON DELETE CASCADE;


--      A
--    /   \
--   B     C
--   |   /   \
--   D  E     F
INSERT INTO tree(node, parent) VALUES
  ('A', NULL),
  ('B', 'A'),
  ('C', 'A'),
  ('D', 'B'),
  ('E', 'C'),
  ('F', 'C');

TABLE tree;


-- What are the labels of the siblings of the node with label E?
SELECT t2.node
FROM   tree AS t1, tree AS t2
WHERE  t1.node = 'E'
AND    t1.parent = t2.parent;


-- What are the labels of the grandchildren of the node with label A?
SELECT t3.node
FROM   tree AS t1, tree AS t2, tree AS t3
WHERE  t1.node = 'A'
AND    t2.parent = t1.node
AND    t3.parent = t2.node;


-- What's the label of the root node?
SELECT t.node
FROM   tree AS t
WHERE  t.parent IS NULL;


-- What are the labels of the leaf nodes?
-- (Node t1 is a leaf if there does not exists a node t2 that has t1 as its parent)
SELECT t1.node
FROM   tree AS t1
WHERE  NOT EXISTS(SELECT 1
                  FROM   tree AS t2
                  WHERE  t2.parent = t1.node);

-- Alternative formulation using NOT IN
-- (Quiz: Why is the IS NOT NULL predicate required?)
SELECT t1.node
FROM   tree AS t1
WHERE  t1.node NOT IN (SELECT t2.parent
                       FROM   tree AS t2
                       WHERE  t2.parent IS NOT NULL);


-- Tree update (new node X, node E becomes a child of new node X):

INSERT INTO tree(node, parent) VALUES
  ('X', 'C');

UPDATE tree AS t
SET    parent = 'X'
WHERE  t.node = 'E';

--      A
--    /   \
--   B     C
--   |   /   \
--   D  X     F
--      |
--      E
TABLE tree;


-- Now delete inner node C in the tree.  How will the resulting
-- tree look like after deletion?
DELETE FROM tree AS t
WHERE  t.node = 'C';

-- Foreign Key Option 1 (ON DELETE SET NULL):
-- Removal of C will set X's and F' parent to NULL,
-- we are left with a three-element forest (= a set of trees)

-- {  A  ,  X  ,  F }
--    |     |
--    B     E
--    |
--    D


-- Foreign Key Option 2 (ON DELETE CASCADE):
-- Deletion of C will lead to the deletion child nodes X and F, whose
-- deletion leads to the deletion of E (subtree under C deleted):

--     A
--     |
--     B
--     |
--     D

TABLE tree;
