# Diagrams as Code (DaC) with D2

## The Concept
Instead of using manual, "click-and-drag" tools like Draw.io or Lucidchart, we use **D2 (Declarative Diagramming)**. This allows us to treat our architecture diagrams exactly like our code.

## Why D2?
- **Version Control:** Diagrams are text files (`.d2`). We can see exactly what changed in a Git diff.
- **Consistency:** No more different font sizes or misaligned boxes. D2 handles the layout automatically.
- **Speed:** Define the relationships (`A -> B`) and let the engine handle the rest.
## The Workflow
1. **Define:** We write the architecture in a `.d2` file.
2. **Render:** We use the `d2` CLI to convert it to an SVG.
3. **Embed:** The SVG is displayed in our Markdown documentation.

## Common Commands

### Render to SVG
The standard command to generate a high-quality vector diagram:
```bash
d2 diagrams/my-diagram.d2 diagrams/my-diagram.svg
```

### Watch Mode
Automatically re-render the diagram whenever the `.d2` file is saved:
```bash
d2 --watch diagrams/my-diagram.d2 diagrams/my-diagram.svg
```

### Layout Engines
D2 supports different layout engines. `dagre` (default) is great for tree-like structures, while `elk` is often better for complex networks:
```bash
d2 --layout elk diagrams/my-diagram.d2 diagrams/my-diagram.svg
```

### Example Syntax:
...

```d2
VPC: {
  Subnet -> EC2: lives in
}
S3: { shape: cylinder }
EC2 -> S3: reads data
```

## Integration in this Project
Every lab includes a corresponding `.d2` and `.svg` file in the `diagrams/` folder. This ensures that as our infrastructure evolves, our documentation stays visually in sync.

## SAA Exam Tip: Visualization
Visualizing the data flow (from IGW to Subnet to EC2) is essential for solving complex SAA scenario questions. Diagrams as Code forces you to think through these connections explicitly.
