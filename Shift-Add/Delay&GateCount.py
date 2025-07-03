import re
from typing import Dict, List, Tuple

class MultiplierAnalyzer:
    def __init__(self):
        # Define gate delays (in nanoseconds)
        self.gate_delays = {
            'and': 1.0,
            'or': 1.0,
            'xor': 1.2,
            'not': 0.5,
            'mux2x1': 1.5,
            'register': 1.0,
            'full_adder': 2.0,
            'comparator': 1.5
        }
        
    def analyze_shifter(self, width: int) -> Dict[str, int]:
        """Analyze gates needed for shifter of given width."""
        return {
            'mux2x1': width,
            'register': width
        }
        
    def analyze_adder(self, width: int) -> Dict[str, int]:
        """Analyze gates needed for adder of given width."""
        return {
            'full_adder': width,
            'and': width * 2,
            'or': width,
            'xor': width
        }
        
    def analyze_multiplier(self, multiplicand_width: int = 32, multiplier_width: int = 32) -> Dict[str, any]:
        """Analyze the complete shift-add multiplier design."""
        # Component counts
        gate_counts = {
            'and': 0,
            'or': 0,
            'xor': 0,
            'not': 0,
            'mux2x1': 0,
            'register': 0,
            'full_adder': 0,
            'comparator': 0
        }
        
        # State registers (2 bits for state)
        gate_counts['register'] += 2
        
        # Counter logic (6-bit counter)
        gate_counts['register'] += 6
        gate_counts['full_adder'] += 6
        gate_counts['comparator'] += 1  # For count < 32 comparison
        
        # Multiplier register (32 bits)
        multiplier_shifter = self.analyze_shifter(multiplier_width)
        for gate, count in multiplier_shifter.items():
            gate_counts[gate] += count
            
        # Multiplicand register (64 bits)
        multiplicand_shifter = self.analyze_shifter(multiplicand_width * 2)
        for gate, count in multiplicand_shifter.items():
            gate_counts[gate] += count
            
        # 64-bit adder for partial products
        adder = self.analyze_adder(multiplicand_width * 2)
        for gate, count in adder.items():
            gate_counts[gate] += count
            
        # Sign handling logic
        gate_counts['xor'] += 1  # Sign comparison
        gate_counts['not'] += 64  # For two's complement
        gate_counts['full_adder'] += 64  # For two's complement addition
        
        # Overflow detection
        gate_counts['comparator'] += 2
        gate_counts['and'] += 4
        gate_counts['or'] += 2
        
        # Calculate critical path delay
        critical_path_delay = self.calculate_critical_path_delay()
        
        return {
            'gate_counts': gate_counts,
            'total_gates': sum(gate_counts.values()),
            'critical_path_delay': critical_path_delay,
            'path_breakdown': self.get_path_breakdown()
        }
        
    def calculate_critical_path_delay(self) -> float:
        """Calculate the critical path delay."""
        # Critical path components:
        # 1. Register clock-to-q
        # 2. Adder delay
        # 3. Multiplexer delay
        # 4. Setup time for next register
        
        register_delay = self.gate_delays['register']
        adder_delay = self.gate_delays['full_adder']
        mux_delay = self.gate_delays['mux2x1']
        setup_time = 0.5  # Typical setup time
        
        return register_delay + adder_delay + mux_delay + setup_time
        
    def get_path_breakdown(self) -> List[str]:
        """Get the breakdown of critical path components."""
        return [
            "Register (clock-to-q delay)",
            "64-bit Adder (partial product addition)",
            "Multiplexer (path selection)",
            "Register (setup time)"
        ]

def analyze_shift_add_multiplier() -> None:
    """Main function to analyze the shift-add multiplier design."""
    analyzer = MultiplierAnalyzer()
    results = analyzer.analyze_multiplier()
    
    # Print analysis results
    print("\n=== Shift-Add Multiplier Analysis ===\n")
    
    print("Gate Count Breakdown:")
    for gate, count in results['gate_counts'].items():
        if count > 0:
            print(f"  {gate.upper()}: {count}")
    
    print(f"\nTotal Gates: {results['total_gates']}")
    
    print("\nTiming Analysis:")
    print(f"  Critical Path Delay: {results['critical_path_delay']:.2f} ns")
    
    print("\nCritical Path Components:")
    for i, component in enumerate(results['path_breakdown'], 1):
        print(f"  {i}. {component}")
        
    print("\nDesign Characteristics:")
    print("  - 32-bit signed multiplication")
    print("  - Shift-and-add algorithm")
    print("  - Three-state FSM (IDLE, MULTIPLY, FINISH)")
    print("  - Overflow detection")
    print("  - Sign handling for signed multiplication")

if __name__ == "__main__":
    analyze_shift_add_multiplier()